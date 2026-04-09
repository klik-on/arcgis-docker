FROM tomcat:9.0.117-jdk11-temurin-jammy

LABEL maintainer="abiyasa@gmail.com" \
      version="ArcGIS WebAdaptor 11.0" \
      description="Web Adaptor for ArcGIS Enterprise 11.0 on Tomcat"

# 1. Update system & Install utility tools
RUN apt-get update && apt-get install -yq --no-install-recommends \
    iputils-ping net-tools \
    vim \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Environment Variables Default
# (Akan di-override jika ada di docker-compose.yml)
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Dfile.encoding=UTF-8"
ENV CATALINA_OPTS="-Xms512M -Xmx1024M"

# 3. Setup Konfigurasi Tomcat & SSL
# Hapus webapps bawaan dan siapkan folder ROOT
RUN rm -rf /usr/local/tomcat/webapps/* && mkdir -p /usr/local/tomcat/webapps/ROOT

# Salin file konfigurasi server dan sertifikat PFX
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY wildcard.pfx /usr/local/tomcat/conf/wildcard.pfx

# 4. Install ArcGIS Web Adaptor 11.0
# File tar.gz akan otomatis di-extract oleh instruksi ADD
ADD ArcGIS_Web_Adaptor_Java_Linux_110_182987.tar.gz /tmp/

# Jalankan installer silent dan deploy file .war
RUN /tmp/WebAdaptor/Setup -m silent -l yes -d / \
    && cp /arcgis/webadaptor11.0/java/arcgis.war /usr/local/tomcat/webapps/server.war \
    && cp /arcgis/webadaptor11.0/java/arcgis.war /usr/local/tomcat/webapps/portal.war \
    && chown -R root:root /usr/local/tomcat/webapps/ \
    && rm -rf /tmp/WebAdaptor

# 5. Script Otomatisasi Registrasi & Halaman Index
COPY index.jsp /usr/local/tomcat/webapps/ROOT/
COPY ap_wa.sh /usr/local/bin/ap_wa.sh
COPY as_wa.sh /usr/local/bin/as_wa.sh

RUN chmod +x /usr/local/bin/ap_wa.sh /usr/local/bin/as_wa.sh

# Port 80 dan 443 diekspos (sesuai setting server.xml)
EXPOSE 80 443

CMD ["catalina.sh", "run"]
