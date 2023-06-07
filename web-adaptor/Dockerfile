FROM tomcat:9.0.75-jdk17-temurin-jammy

MAINTAINER Klik.On <abiyasa@gmail.com>

LABEL version="ArcGIS WebAdaptor 10.9.1" \
          author="Klik.On" \
          description="This is for Klik.On"

# Change from port 8080 to port 80.
RUN sed -i "s/8080/80/" /usr/local/tomcat/conf/server.xml
# Remove the redirect
RUN sed -i "s/redirectPort=\"8443\"//g" /usr/local/tomcat/conf/server.xml


# Create and install a self-signed certificate. ***star.menlhk.go.id.pfx
RUN keytool -genkey -alias tomcat -keyalg RSA -storetype PKCS12 -keystore /home/tomcat.keystore \
    -storepass 123456 -keypass 123456 -validity 365 \
    -dname "CN=*.WEBGIS.LOKAL, OU=IPSDH, O=Kementerian Lingkungan Hidup dan Kehutanan, L=Jakarta Pusat, ST=DKI Jakarta, C=ID"
# Modify server.xml to activate the TLS service
RUN sed -i "s/<Service name=\"Catalina\">/<Service name=\"Catalina\">\n    <Connector port=\"443\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" keystorePass=\"123456\" clientAuth=\"false\" sslProtocol=\"TLS\" keystoreFile=\"\/home\/fullchain.pfx\" \/>/" \
    /usr/local/tomcat/conf/server.xml

# Close the Tomcatfullchain.pfx
RUN /usr/local/tomcat/bin/shutdown.sh

# Update apt-get and instal some tools
RUN apt-get update && apt install -y iputils-ping vim

# start for arcgis webadaptor
COPY wa_run /tmp/
COPY *_wa.sh /tmp/
COPY index.jsp /tmp/
COPY readme.md /tmp/
COPY FIXED.txt /tmp/
COPY nginx*.conf /tmp/
ADD ArcGIS_Web_Adaptor_Java_Linux_109*.tar.gz /tmp/
COPY star* /home/

EXPOSE 80 443

RUN /tmp/WebAdaptor/Setup -m silent -l yes -d /
RUN rm -rf /tmp/WebAdaptor
RUN cp /arcgis/webadaptor10.9.1/java/arcgis.war /usr/local/tomcat/webapps/server.war
RUN cp /arcgis/webadaptor10.9.1/java/arcgis.war /usr/local/tomcat/webapps/portal.war

RUN mkdir -p /usr/local/tomcat/webapps/ROOT
RUN cp /tmp/index.jsp  /usr/local/tomcat/webapps/ROOT/

CMD /usr/local/tomcat/bin/startup.sh && tail -f /usr/local/tomcat/logs/catalina.out
