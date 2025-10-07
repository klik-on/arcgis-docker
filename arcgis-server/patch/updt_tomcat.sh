# docker exec -it SERVER /bin/bash
# wget https://raw.githubusercontent.com/klik-on/arcgis-docker/main/arcgis-server/patch/updt_tomcat.sh
# docker restart {SERVER,PORTAL,DATASTORE}

/home/arcgis/server/framework/runtime/tomcat/bin/version.sh

tver='9.0.110'
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v$tver/bin/apache-tomcat-$tver.tar.gz
tar -xvf apache-tomcat-$tver.tar.gz

/home/arcgis/server/stopserver.sh
cd /home/arcgis/server/framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak

cp -fv /tmp/apache-tomcat-$tver/bin/*.jar /home/arcgis/server/framework/runtime/tomcat/bin/
cp -fv /tmp/apache-tomcat-$tver/lib/*.jar /home/arcgis/server/framework/runtime/tomcat/lib/
/home/arcgis/server/framework/runtime/tomcat/bin/version.sh

/home/arcgis/server/startserver.sh

rm -rf /tmp/apache-tomcat-$tver*
