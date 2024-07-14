# docker exec -it PORTAL /bin/bash
# docker restart {SERVER,PORTAL,DATASTORE}
 /home/arcgis/portal/framework/runtime/tomcat/bin/version.sh

tver='9.0.91'
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v$tver/bin/apache-tomcat-$tver.tar.gz
tar -xvf apache-tomcat-$tver.tar.gz

/home/arcgis/portal/stopportal.sh
cd /home/arcgis/portal/framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak

cp -fv /tmp/apache-tomcat-$tver/bin/*.jar /home/arcgis/portal/framework/runtime/tomcat/bin/
cp -fv /tmp/apache-tomcat-$tver/lib/*.jar /home/arcgis/portal/framework/runtime/tomcat/lib/
/home/arcgis/portal/framework/runtime/tomcat/bin/version.sh

/home/arcgis/portal/startportal.sh

rm -rf /tmp/apache-tomcat-$tver*
