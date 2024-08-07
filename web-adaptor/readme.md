Apache Tomcat
https://github.com/docker-library/tomcat

/etc/hosts lokal server tambahkan
IP  SERVER.WEBGIS.LOKAL PORTAL.WEBGIS.LOKAL DATASTORE.WEBGIS.LOKAL


###webadaptor docker run
$ docker build -t arcgis/webadaptor:10.9.1 .

$ docker run -d --name=webadaptor \
  --hostname=webadaptor.arcgis.lan \
  -p 8080:80 -p 8443:443 \
  --restart=always \  
arcgis/webadaptor:10.9.1

### port 80/443 ==> tanpa reserve proxy
$ docker run -d --name=webadaptor \
  --hostname=agsipsdh.menlhk.go.id \
  -p 80:80 -p 443:443 \
  --restart=always \
  arcgis/webadaptor:10.9.1

### Update Test
docker run -d --name=webadaptor \
  --hostname=webadaptor.arcgis.lan \
  -p 8080:80 -p 8443:443 \
  --restart=always \
webadaptor:9.0.68

### only config http
$ docker exec -it webadaptor bash /arcgis/webadaptor10.9.1/java/tools/configurewebadaptor.sh -m server -w http://wbgis.ddns.net/arcgis/webadaptor -g http://server.arcgis.lan:6080 -u siteadmin -p TEST2022 -a true
## https   (config https include http)
$ docker exec -it webadaptor bash /arcgis/webadaptor10.9.1/java/tools/configurewebadaptor.sh -m server \
-w https://wbgis.ddns.net/server/webadaptor \
-g https://server.arcgis.lan:6443 \
-u siteadmin -p TEST2022 -a true
$ docker exec -it webadaptor bash /arcgis/webadaptor10.9.1/java/tools/configurewebadaptor.sh -m portal -w https://wbgis.ddns.net/portal/webadaptor -g https://portal.arcgis.lan:7443 -u portaladmin -p TEST2022



$ docker exec -it webadaptor /bin/bash
#### Forward to HTTPS/SSL
                keystoreFile="/home/wbgis.ddns.net.pfx"
                keystorePass="123456" />
# vi conf/web.xml  tekan ]]
Tambahkan diakhir baris sebelum  tag </web-app>

    <security-constraint>
        <web-resource-collection>
        <web-resource-name>Automatic Forward to HTTPS/SSL
        </web-resource-name>
        <url-pattern>/*</url-pattern>
        </web-resource-collection>
        <user-data-constraint>
           <transport-guarantee>CONFIDENTIAL</transport-guarantee>
        </user-data-constraint>
    </security-constraint>

</web-app>

# cd /usr/local/tomcat/webapps
# mkdir ROOT
# vi ROOT/index.jsp
<% response.sendRedirect("/portal"); %>



#### proxy nginx
# vi /etc/nginx/sites-available/virtual.host.conf
server {
    listen 80;
   server_name wbgis.ddns.net;
    return 301 https://$host$request_uri;
}

server {

    listen 443 ssl;
    server_name wbgis.ddns.net;
    access_log /var/log/nginx/arcgisserver.access.log;

    # Necessary for when people push larger SD files
    client_max_body_size 50M;

    ssl_certificate  /home/wbgis.ddns.net.pem;
    ssl_certificate_key /home/wbgis.ddns.net.key;

    ssl_session_cache builtin:1000 shared:SSL:10m;

    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";

    ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off; # Requires nginx >= 1.5.9
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

    location /portal {

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass https://127.0.0.1:8443;
        proxy_read_timeout 90;
        proxy_redirect http://127.0.0.1:8443 https://wbgis.ddns.netd;

    }

    location /server {

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass https://127.0.0.1:8443;
        proxy_read_timeout 90;
        proxy_redirect http://127.0.0.1:8443 https://wbgis.ddns.net;

    }
}


#####
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/virtual.host.conf /etc/nginx/sites-enabled/virtual.host.conf
sudo service nginx configtest
sudo service nginx restart

