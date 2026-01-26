#!/bin/bash

# --- KONFIGURASI ---
ROOT_DIR="gateway-server"
APP_SERVER_IP="172.16.2.122"
GATEWAY_IP="172.16.2.130"

echo "🚀 Membangun Gateway Server (Full: Frontend, API, Swagger, Flower)..."

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

    # Optimasi timeout untuk proses GIS & Celery yang lama
    proxy_read_timeout 600;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;

    # --- 1. FRONTEND (React) ---
    location / {
        proxy_pass http://$APP_SERVER_IP:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- 2. BACKEND API (FastAPI) ---
    location /api/v1 {
        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_buffering off;
    }

    # --- 3. DOKUMENTASI API (/datagis) ---
    # Menggunakan sub_filter karena FastAPI mengirim path root secara default
    location /datagis {
        rewrite ^/datagis/?$ /docs break;
        rewrite ^/datagis/(.*)$ /\$1 break;
        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;

        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter "'./openapi.json'" "'/datagis/openapi.json'";
        sub_filter '/static' '/datagis/static';
        sub_filter_once off;
        sub_filter_types text/html text/css application/javascript;
        proxy_set_header Accept-Encoding ""; 
    }

    location /datagis/openapi.json {
        proxy_pass http://$APP_SERVER_IP:8000/openapi.json;
    }

    location /datagis/static/ {
        rewrite ^/datagis/static/(.*)$ /static/\$1 break;
        proxy_pass http://$APP_SERVER_IP:8000;
    }

    # --- 4. MONITORING (Flower) ---
    # Sesuai dengan --url-prefix=flower di backend
    location /flower/ {
        # Tanpa slash di akhir agar /flower diteruskan ke backend
        proxy_pass http://$APP_SERVER_IP:5555;
        
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        # WebSocket support untuk real-time worker updates
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "--------------------------------------------------------"
echo "✅ Konfigurasi Selesai!"
echo "📍 Folder Skrip  : $ROOT_DIR"
echo "📖 Dokumentasi   : http://$GATEWAY_IP/datagis"
echo "🌸 Celery Flower : http://$GATEWAY_IP/flower/"
echo "--------------------------------------------------------"
echo "🚀 Eksekusi perintah di bawah ini:"
echo "cd $ROOT_DIR && docker compose up -d --force-recreate"
