# docker exec -it DATASTORE /bin/bash
# docker restart {SERVER,PORTAL,DATASTORE}
 /home/arcgis/datastore/framework/runtime/tomcat/bin/version.sh

tver='9.0.87'
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v$tver/bin/apache-tomcat-$tver.tar.gz
tar -xvf apache-tomcat-$tver.tar.gz

/home/arcgis/datastore/stopdatastore.sh
cd /home/arcgis/datastore/framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak

cp -fv /tmp/apache-tomcat-$tver/bin/*.jar /home/arcgis/datastore/framework/runtime/tomcat/bin/
cp -fv /tmp/apache-tomcat-$tver/lib/*.jar /home/arcgis/datastore/framework/runtime/tomcat/lib/
/home/arcgis/datastore/framework/runtime/tomcat/bin/version.sh

/home/arcgis/datastore/startdatastore.sh

rm -rf /tmp/apache-tomcat-$tver*
