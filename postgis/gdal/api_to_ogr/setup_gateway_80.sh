#!/bin/bash

# --- KONFIGURASI ---
ROOT_DIR="gateway-server"
APP_SERVER_IP="172.16.2.122"
GATEWAY_IP="172.16.2.130"

echo "🚀 Menyusun Gateway Server Geospasial (Mode Sederhana)..."

# 1. Membuat struktur direktori
mkdir -p $ROOT_DIR/nginx/conf.d

# 2. Membuat file docker-compose.yml
cat <<EOF > $ROOT_DIR/docker-compose.yml
services:
  gateway:
    image: nginx:stable-alpine
    container_name: geo-gateway
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# 3. Membuat file nginx/conf.d/default.conf
cat <<EOF > $ROOT_DIR/nginx/conf.d/default.conf
server {
    listen 80;
    server_name $GATEWAY_IP;

    # Optimasi timeout untuk transmisi data GeoJSON besar
    proxy_read_timeout 600;
    proxy_connect_timeout 600;

    # --- 1. FRONTEND (React) ---
    location / {
        proxy_pass http://$APP_SERVER_IP:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- 2. BACKEND API ---
    location /api/v1 {
        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_buffering off;
    }

    # --- 3. DOKUMENTASI API (Fix Path Swagger) ---
    location /datagis {
        # Redirect ke /docs di backend
        rewrite ^/datagis/?$ /docs break;
        rewrite ^/datagis/(.*)$ /\$1 break;

        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;

        # Sinkronisasi rute dalam body HTML (Meniru Java Servlet)
        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter "'./openapi.json'" "'/datagis/openapi.json'";
        sub_filter '/static' '/datagis/static';
        sub_filter_once off;
        sub_filter_types text/html text/css application/javascript;

        # Mematikan kompresi agar sub_filter bisa membaca body
        proxy_set_header Accept-Encoding ""; 
    }

    # Endpoint JSON yang dicari oleh Swagger UI
    location /datagis/openapi.json {
        proxy_pass http://$APP_SERVER_IP:8000/openapi.json;
        proxy_set_header Host \$host;
    }

    # Penanganan aset statis (CSS/JS) untuk UI dokumentasi
    location /datagis/static/ {
        rewrite ^/datagis/static/(.*)$ /static/\$1 break;
        proxy_pass http://$APP_SERVER_IP:8000;
    }
}
EOF

echo "--------------------------------------------------------"
echo "✅ Setup Selesai tanpa API_KEY manual di Nginx."
echo "📖 Dokumentasi: http://$GATEWAY_IP/datagis"
echo "--------------------------------------------------------"
echo "🚀 Jalankan: cd $ROOT_DIR && docker compose up -d"
