 /home/arcgis/server/framework/runtime/tomcat/bin/version.sh

cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.76/bin/apache-tomcat-9.0.76.tar.gz
tar -xvf apache-tomcat-9.0.76.tar.gz

/home/arcgis/server/stopserver.sh
cd /home/arcgis/server/framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak

cp -fv /tmp/apache-tomcat-9.0.76/bin/*.jar /home/arcgis/server/framework/runtime/tomcat/bin/
cp -fv /tmp/apache-tomcat-9.0.76/lib/*.jar /home/arcgis/server/framework/runtime/tomcat/lib/
 /home/arcgis/server/framework/runtime/tomcat/bin/version.sh

/home/arcgis/server/startserver.sh

rm -rf /tmp/apache-tomcat-9*
