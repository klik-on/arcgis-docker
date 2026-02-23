#!/bin/bash

# ============================================================
# 1. KONFIGURASI
# ============================================================
ROOT_DIR="gateway-server"
APP_SERVER_IP="192.16.12.122"   # Server Backend & Frontend
GATEWAY_IP="192.16.12.130"      # Server Gateway

# Kredensial Admin (Flower & Minio)
ADMIN_USER="flower"
ADMIN_PASS="flower-pass-****"

echo "🚀 [$(date)] Updating Gateway with Gzip & GIS Optimization..."

# Buat direktori kerja
mkdir -p $ROOT_DIR/nginx/conf.d

# --- GENERATE HT PASSWD ---
ENCRYPTED_PASS=$(docker run --rm alpine sh -c "apk add --no-cache openssl > /dev/null && openssl passwd -apr1 '$ADMIN_PASS'")
echo "$ADMIN_USER:$ENCRYPTED_PASS" > $ROOT_DIR/nginx/.htpasswd

# ============================================================
# 2. DOCKER COMPOSE GATEWAY
# ============================================================
cat <<EOF > $ROOT_DIR/docker-compose.yml
version: "3.9"
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
    networks:
      geo-net:
        ipv4_address: 192.168.70.60

networks:
  geo-net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.70.0/24
EOF

# ============================================================
# 3. NGINX CONFIGURATION (WITH GZIP & GIS OPTIMIZATION)
# ============================================================
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

    # --- TIMEOUT & SIZE CONFIG ---
    client_max_body_size 100M;
    proxy_read_timeout 600;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_buffering off;

    # --- 1. BACKEND API & MVT TILES ---
    location /datagis/api/v1/ {
        proxy_pass http://$APP_SERVER_IP:8000/datagis/api/v1/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        add_header 'Access-Control-Allow-Origin' '*' always;
    }

    # --- 2. DOKUMENTASI API (Swagger) ---
    location /datagis {
        rewrite ^/datagis/?$ /datagis/docs/ permanent;
        proxy_pass http://$APP_SERVER_IP:8000;
        proxy_set_header Host \$host;
        sub_filter '"/openapi.json"' '"/datagis/openapi.json"';
        sub_filter_once off;
        sub_filter_types text/html;
    }

    # --- 3. FLOWER MONITORING (FIXED) ---
    location = /flower { return 301 \$scheme://\$http_host/flower/; }
    location /flower/ {
        auth_basic "Restricted Access - GIS Monitor";
        auth_basic_user_file /etc/nginx/.htpasswd;

        # Sesuaikan dengan --url_prefix=flower di backend
        proxy_pass http://$APP_SERVER_IP:5555/flower/;
        
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # --- 4. MINIO CONSOLE ---
    location /geobackup/ {
        auth_basic "Restricted Access - Geo Storage";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://$APP_SERVER_IP:9001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Prefix /geobackup;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # --- 5. MINIO S3 API ---
    location /s3api/ {
        proxy_pass http://$APP_SERVER_IP:9000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # --- 6. FRONTEND (React) ---
    location / {
        proxy_pass http://$APP_SERVER_IP:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# ============================================================
# 4. EKSEKUSI
# ============================================================
cd $ROOT_DIR
echo "🔄 Me-restart gateway..."
docker-compose down || true
docker-compose up -d

echo "--------------------------------------------------------"
echo "✅ GATEWAY BERHASIL DIUPDATE DENGAN OPTIMASI GZIP"
echo "🌸 Flower : http://$GATEWAY_IP/flower/"
echo "⚙️  Gzip   : Enabled (JSON & GeoJSON)"
echo "⏱️  Timeout: 600s (Koneksi Stabil)"
echo "--------------------------------------------------------"
