FROM tomcat:9.0.110-jdk11-temurin-jammy

MAINTAINER Klik.On <abiyasa@gmail.com>

LABEL version="ArcGIS WebAdaptor 10.9.1" \
          author="Klik.On" \
          description="This is for Klik.On"

# Change from port 8080 to port 80.
RUN sed -i "s/8080/80/" /usr/local/tomcat/conf/server.xml
# Remove the redirect
RUN sed -i "s/redirectPort=\"8443\"//g" /usr/local/tomcat/conf/server.xml


# Create and install a self-signed certificate.
RUN keytool -genkey -alias tomcat -keyalg RSA -storetype PKCS12 -keystore /home/wildcard.pfx \
    -storepass P4ssw0rd@1 -keypass P4ssw0rd@1 -validity 36500 \
    -dname "CN=*.WEBGIS.LOKAL, OU=TEST, O=LHK, L=Jakarta Pusat, ST=DKI Jakarta, C=ID"
# Modify server.xml to activate the TLS service
RUN sed -i "s/<Service name=\"Catalina\">/<Service name=\"Catalina\">\n    <Connector protocol=\"org.apache.coyote.http11.Http11NioProtocol\"\n       port=\"443\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\"\n       keystoreFile=\"\/home\/wildcard.pfx\" keystorePass=\"P4ssw0rd@1\"\n       clientAuth=\"false\" sslProtocol=\"TLS\" \/>/" \
/usr/local/tomcat/conf/server.xml

# Forward to HTTPS/SSL
RUN sed -i 's|</web-app>|    <security-constraint>\n \
        <web-resource-collection>\n \
        <web-resource-name>Automatic Forward to HTTPS/SSL\n \
        </web-resource-name>\n \
        <url-pattern>/*</url-pattern>\n \
        </web-resource-collection>\n \
        <user-data-constraint>\n \
           <transport-guarantee>CONFIDENTIAL</transport-guarantee>\n \
        </user-data-constraint>\n \
    </security-constraint>\n \
</web-app> |g' /usr/local/tomcat/conf/web.xml


# Close the Tomcat
# RUN /usr/local/tomcat/bin/shutdown.sh

# Update apt-get and instal some tools
RUN apt-get update && apt install -y iputils-ping vim tzdata

# Set Timezone
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Add geoserver 
# ADD https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip/download geoserver.war.zip
# ADD https://sourceforge.net/projects/geowebcache/files/geowebcache/${GEOWEBCACHE_VERSION}/geowebcache-${GEOWEBCACHE_VERSION}-war.zip/download geowebcache.war.zip

# start for arcgis webadaptor
COPY wa_run /tmp/
COPY *_wa.sh /tmp/
COPY index.jsp /tmp/
COPY readme.md /tmp/
COPY FIXED.txt /tmp/
COPY nginx*.conf /tmp/
ADD ArcGIS_Web_Adaptor_Java_Linux_109*.tar.gz /tmp/
COPY wildcard.pfx /home/
COPY ./conf/*.xml /tmp/
COPY ./proxy/ /usr/local/tomcat/webapps/proxy/
COPY updt_tomcat.sh /usr/local/tomcat/temp/

EXPOSE 80 443

# RUN /tmp/WebAdaptor/Setup -m silent -l yes -d /
RUN /tmp/WebAdaptor/Setup -m silent -l yes -d / || (echo "Install gagal" && exit 1)
RUN rm -rf /tmp/WebAdaptor
RUN cp /arcgis/webadaptor10.9.1/java/arcgis.war /usr/local/tomcat/webapps/server.war
RUN cp /arcgis/webadaptor10.9.1/java/arcgis.war /usr/local/tomcat/webapps/portal.war

RUN mkdir -p /usr/local/tomcat/webapps/ROOT
RUN cp /tmp/index.jsp  /usr/local/tomcat/webapps/ROOT/
# RUN cp /tmp/web.xml /usr/local/tomcat/conf/

CMD /usr/local/tomcat/bin/startup.sh && tail -f /usr/local/tomcat/logs/catalina.out

# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*
