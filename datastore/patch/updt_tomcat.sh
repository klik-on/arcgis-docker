 /home/arcgis/datastore/framework/runtime/tomcat/bin/version.sh

cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.78/bin/apache-tomcat-9.0.78.tar.gz
tar -xvf apache-tomcat-9.0.78.tar.gz

/home/arcgis/datastore/stopdatastore.sh
cd /home/arcgis/datastore/framework/runtime/tomcat/
cp -r bin bin_bak
cp -r lib lib_bak

cp -fv /tmp/apache-tomcat-9.0.78/bin/*.jar /home/arcgis/datastore/framework/runtime/tomcat/bin/
cp -fv /tmp/apache-tomcat-9.0.78/lib/*.jar /home/arcgis/datastore/framework/runtime/tomcat/lib/
/home/arcgis/datastore/framework/runtime/tomcat/bin/version.sh

/home/arcgis/datastore/startdatastore.sh

rm -rf /tmp/apache-tomcat-9*
