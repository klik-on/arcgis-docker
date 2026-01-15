import os
import logging
import secrets
import pandas as pd
from fastapi import FastAPI, HTTPException, Depends, Security, status, Query
from fastapi.security import APIKeyHeader
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, text
import geopandas as gpd
from contextlib import asynccontextmanager

# --- 1. KONFIGURASI LOGGING ---
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("api-to-ogr")

# --- 2. ENV VARIABLES ---
def get_env_or_critical(key: str) -> str:
    value = os.getenv(key)
    if not value: raise RuntimeError(f"Missing env var: {key}")
    return value

DB_USER = get_env_or_critical("DB_USER")
DB_PASS = get_env_or_critical("DB_PASS")
DB_HOST = get_env_or_critical("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = get_env_or_critical("DB_NAME")
PGIS_API_TOKEN = get_env_or_critical("PGIS_API_TOKEN")

DATABASE_URL = f"postgresql+psycopg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# --- 3. SECURITY ---
api_key_header = APIKeyHeader(name="X-API-TOKEN", auto_error=False)
async def get_api_key(api_key: str = Security(api_key_header)):
    if api_key and secrets.compare_digest(api_key, PGIS_API_TOKEN): return api_key
    raise HTTPException(status_code=401, detail="Token tidak valid")

# --- 4. ENGINE ---
engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 API Data Spasial Kehutanan Memulai...")
    yield
    engine.dispose()

app = FastAPI(title="GIS API - Data Spasial Kehutanan", version="1.2.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# --- 5. ENDPOINTS: EKSPLORASI ---

@app.get("/api/v1/list-schemas", tags=["Eksplorasi Data"])
def list_schemas(_=Depends(get_api_key)):
    query = "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog') ORDER BY schema_name;"
    with engine.connect() as conn:
        result = conn.execute(text(query))
        return {"schemas": [row[0] for row in result]}

@app.get("/api/v1/list-tables/{schema_name}", tags=["Eksplorasi Data"])
def list_tables(schema_name: str, search: str = Query(None), _=Depends(get_api_key)):
    query_str = "SELECT table_name FROM information_schema.tables WHERE table_schema = :schema AND table_type = 'BASE TABLE'"
    params = {"schema": schema_name}
    if search:
        query_str += " AND table_name ILIKE :search"
        params["search"] = f"%{search}%"
    with engine.connect() as conn:
        result = conn.execute(text(query_str + " ORDER BY table_name;"), params)
        return {"schema": schema_name, "count": len(tables := [row[0] for row in result]), "tables": tables}

# --- 6. ENDPOINTS: API DATA KEHUTANAN ---

@app.get("/api/v1/layers/{schema_name}/{table_name}", tags=["API Data Kehutanan"])
def get_spatial_layer(schema_name: str, table_name: str, page: int = Query(1), limit: int = Query(500), geom_column: str = "geom", _=Depends(get_api_key)):
    """Output: GeoJSON (Dengan Geometri)"""
    try:
        offset = (page - 1) * limit
        sql = f'SELECT * FROM "{schema_name}"."{table_name}" LIMIT :limit OFFSET :offset'
        with engine.connect() as conn:
            gdf = gpd.read_postgis(text(sql), conn, geom_col=geom_column, params={"limit": limit, "offset": offset})
        res = gdf.__geo_interface__
        res["metadata"] = {"schema": schema_name, "table": table_name, "page": page, "count": len(gdf)}
        return res
    except Exception: raise HTTPException(status_code=500, detail="Gagal ambil data spasial")

@app.get("/api/v1/tables/{schema_name}/{table_name}", tags=["API Data Kehutanan"])
def get_table_data(schema_name: str, table_name: str, page: int = Query(1), limit: int = Query(500), _=Depends(get_api_key)):
    """Output: JSON Biasa (Hanya Tabel/Atribut, Tanpa Geometri)"""
    try:
        offset = (page - 1) * limit
        sql = f'SELECT * FROM "{schema_name}"."{table_name}" LIMIT :limit OFFSET :offset'
        with engine.connect() as conn:
            df = pd.read_sql(text(sql), conn, params={"limit": limit, "offset": offset})
        if df.empty: return {"data": [], "metadata": {"status": "empty"}}
        
        # Buang kolom geometri secara otomatis
        df = df.drop(columns=[c for c in df.columns if c.lower() in ['geom', 'geometry', 'shape']], errors='ignore')
        return {"metadata": {"schema": schema_name, "table": table_name, "page": page, "count": len(df)}, "data": df.to_dict(orient="records")}
    except Exception: raise HTTPException(status_code=500, detail="Gagal ambil data tabel")

@app.get("/api/v1/stats/{schema_name}/{table_name}", tags=["API Data Kehutanan"])
def get_table_stats(schema_name: str, table_name: str, _=Depends(get_api_key)):
    with engine.connect() as conn:
        total = conn.execute(text(f'SELECT COUNT(*) FROM "{schema_name}"."{table_name}"')).scalar()
        return {"schema": schema_name, "table": table_name, "total_records": total}

@app.get("/health", tags=["Sistem"])
def health_check():
    return {"status": "healthy"}
