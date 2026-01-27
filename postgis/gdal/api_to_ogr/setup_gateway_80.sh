#!/bin/bash

# =================================================================
# SKRIP SETUP GATEWAY GEOSPASIAL (PORT 80)
# Proteksi: Basic Auth untuk Flower
# Optimasi: Gzip untuk GeoJSON & Sub-filter Swagger
# =================================================================

# --- 1. KONFIGURASI ---
ROOT_DIR="gateway-server"
APP_SERVER_IP="172.16.2.122"   # Server Backend/Frontend
GATEWAY_IP="172.16.2.130"      # Server ini (Gateway)

echo "🚀 Membangun Gateway Server di $GATEWAY_IP..."

# Persiapan Folder
mkdir -p $ROOT_DIR/nginx/conf.d

# Cek apakah file .htpasswd sudah ada, jika belum buat dummy (admin:admin)
if [ ! -f "$ROOT_DIR/nginx/.htpasswd" ]; then
    echo "⚠️ File .htpasswd tidak ditemukan. Membuat user default (admin:admin123)..."
    echo "admin:\$apr1\$vS7Esq6z\$8X/L.Xp6YhE6mQ.tLh/mJ/" > $ROOT_DIR/nginx/.htpasswd
    echo "👉 Silakan ganti password nanti menggunakan command 'htpasswd'."
fi

# --- 2. DOCKER COMPOSE GATEWAY ---
cat <<EOF > $ROOT_DIR/docker-compose.yml
services:
  gateway:
    image: nginx:stable-alpine
    container_name: geo-gateway
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/.htpasswd:/etc/nginx/.htpasswd:ro
EOF

# --- 3. NGINX CONFIGURATION ---
# Menggunakan '\$' untuk variabel internal Nginx agar tidak diproses oleh Bash
cat <<EOF > $ROOT_DIR/nginx/conf.d/default.conf
server {
    listen 80;
    server_name $GATEWAY_IP;

    # --- OPTIMASI GZIP (Untuk GeoJSON Besar) ---
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript application/xml application/geo+json application/vnd.geo+json;
    gzip_min_length 1024;

    proxy_read_timeout 600;
    proxy_connect_timeout 600;

    # --- 1. FRONTEND ---
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

    # --- 3. DOKUMENTASI API (SWAGGER) ---
    location /datagis {
        # Redirect otomatis /datagis ke /datagis/docs/
        rewrite ^/datagis/?$ /datagis/docs/ permanent;

        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;
        proxy_set_header Accept-Encoding ""; 

        # Injeksi path sub-direktori agar Swagger UI tidak broken
        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter "'./openapi.json'" "'/datagis/openapi.json'";
        sub_filter '/static' '/datagis/static';
        sub_filter_once off;
        sub_filter_types text/html text/css application/javascript;
    }

    location /datagis/openapi.json {
        proxy_pass http://$APP_SERVER_IP:8000/openapi.json;
    }

    # --- 4. FLOWER MONITORING (PROTECTED) ---
    location /flower/ {
        auth_basic "Restricted Access: Geo-Monitor";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_pass http://$APP_SERVER_IP:5555;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "--------------------------------------------------------"
echo "✅ Konfigurasi Berhasil Dibuat!"
echo "📍 Lokasi: $ROOT_DIR"
echo "🚀 Menjalankan Docker Gateway..."
echo "--------------------------------------------------------"

cd $ROOT_DIR
docker-compose down --remove-orphans
docker-compose up -d

echo "--------------------------------------------------------"
echo "🎉 GATEWAY SELESAI DIINSTAL"
echo "🔗 Frontend: http://$GATEWAY_IP/"
echo "📖 API Docs: http://$GATEWAY_IP/datagis/"
echo "🌸 Flower:   http://$GATEWAY_IP/flower/"
echo "--------------------------------------------------------"

# ganti password default
# htpasswd -bc ./gateway-server/nginx/.htpasswd admin password_baru_anda
# cd gateway-server && docker-compose restart gateway
