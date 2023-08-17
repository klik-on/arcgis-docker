# apt update
# apt install nano
# nano /etc/nginx/conf.d/ssl.conf
# ssl_certificate /etc/ssl/private/nginx.crt;
# ssl_certificate_key /etc/ssl/private/nginx.key;
# ubah menjadi
# ssl_certificate /etc/nginx/ssl/fullchain.pem;
# ssl_certificate_key /etc/nginx/ssl/privkey.pem;

for ssl in *.pem; do
  docker cp $ssl fme-nginx-1:/etc/nginx/ssl
done
