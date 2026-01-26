#!/bin/bash

# --- KONFIGURASI ---
ROOT_DIR="gateway-server"
APP_SERVER_IP="172.16.2.122"
GATEWAY_IP="172.16.2.130"
# Masukkan API Key yang sama dengan di config.properties Java jika backend mewajibkan
API_KEY="YOUR_API_KEY_DISINI"

echo "🚀 Menyusun Gateway Server Geospasial (Nginx-Native Proxy Mode)..."

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

    # Optimasi timeout untuk proses spasial berat
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
        proxy_set_header X-API-TOKEN "$API_KEY";
        proxy_set_header apikey "$API_KEY";
        proxy_buffering off;
    }

    # --- 3. DOKUMENTASI API (Logika Java Proxy Servlet) ---
    location /datagis {
        # Sesuai logika: (pathInfo == null || pathInfo.equals("/")) ? "/docs" : pathInfo;
        rewrite ^/datagis/?$ /docs break;
        rewrite ^/datagis/(.*)$ /\$1 break;

        proxy_pass http://$APP_SERVER_IP:8000;

        # Forward API Key
        proxy_set_header X-API-TOKEN "$API_KEY";
        proxy_set_header apikey "$API_KEY";
        proxy_set_header Host \$host;

        # LOGIKA REWRITE BODY (Persis replace di Java)
        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter "'./openapi.json'" "'/datagis/openapi.json'";
        sub_filter '/static' '/datagis/static';
        sub_filter_once off;
        sub_filter_types text/html text/css application/javascript;

        # Penting: Matikan kompresi agar Nginx bisa membaca & mengubah teks body
        proxy_set_header Accept-Encoding ""; 
    }

    # Penanganan file openapi.json
    location /datagis/openapi.json {
        proxy_pass http://$APP_SERVER_IP:8000/openapi.json;
        proxy_set_header Host \$host;
    }

    # Penanganan aset statis (CSS/JS) Swagger
    location /datagis/static/ {
        rewrite ^/datagis/static/(.*)$ /static/\$1 break;
        proxy_pass http://$APP_SERVER_IP:8000;
    }

    # --- 4. HEALTH CHECK ---
    location /health {
        proxy_pass http://$APP_SERVER_IP:8000/health;
    }
}
EOF

echo "--------------------------------------------------------"
echo "✅ Gateway Berhasil Dikonfigurasi!"
echo "🌐 Akses UI: http://$GATEWAY_IP"
echo "📖 Dokumentasi: http://$GATEWAY_IP/datagis"
echo "--------------------------------------------------------"
echo "🚀 Jalankan: cd $ROOT_DIR && docker-compose up -d"
