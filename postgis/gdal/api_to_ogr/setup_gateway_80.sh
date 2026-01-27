#!/bin/bash

## Persiapan
# sudo apt-get install apache2-utils -y
# mkdir -p gateway-server/nginx
# htpasswd -bc ./gateway-server/nginx/.htpasswd admin password_anda

# --- KONFIGURASI ---
ROOT_DIR="gateway-server"
APP_SERVER_IP="172.16.2.122"
GATEWAY_IP="172.16.2.130"

echo "🚀 Membangun Gateway Server dengan Proteksi Flower & Optimasi Gzip..."

# Buat struktur folder
mkdir -p $ROOT_DIR/nginx/conf.d

# --- 1. DOCKER COMPOSE GATEWAY ---
cat <<EOF > $ROOT_DIR/docker-compose.yml
services:
  gateway:
    image: nginx:stable-alpine
    container_name: geo-gateway
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      # Mapping file satu per satu untuk menghindari konflik read-only folder
      - ./nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/.htpasswd:/etc/nginx/.htpasswd:ro
EOF

# --- 2. NGINX CONFIGURATION ---
# Gunakan EOF tanpa kutipan untuk mengizinkan substitusi variabel IP Bash ke file
cat <<EOF > $ROOT_DIR/nginx/conf.d/default.conf
server {
    listen 80;
    server_name $GATEWAY_IP;

    # --- OPTIMASI GZIP ---
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    # text/html tidak ditulis karena default Nginx sudah menyertakannya
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
        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;
        proxy_set_header Accept-Encoding ""; 

        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter "'./openapi.json'" "'/datagis/openapi.json'";
        sub_filter '/static' '/datagis/static';
        sub_filter_once off;
        sub_filter_types text/html text/css application/javascript;
    }

    location /datagis/openapi.json {
        proxy_pass http://$APP_SERVER_IP:8000/openapi.json;
    }

    # --- 4. FLOWER DENGAN PROTEKSI PASSWORD ---
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
echo "✅ Konfigurasi Gateway Berhasil Dimodifikasi!"
echo "🚀 Jalankan perintah berikut:"
echo "cd $ROOT_DIR && docker-compose down && docker-compose up -d"
