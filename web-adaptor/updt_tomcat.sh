# docker exec -it WEBADAPTOR /bin/bash

cd temp
tver='9.0.83'
wget https://dlcdn.apache.org/tomcat/tomcat-9/v$tver/bin/apache-tomcat-$tver.tar.gz
tar -xvf apache-tomcat-$tver.tar.gz
cd /usr/local/tomcat
./bin/version.sh
cp -r bin bin_bak
cp -r lib lib_bak
cp -fv ./temp/apache-tomcat-$tver/bin/*.jar ./bin
cp -fv ./temp/apache-tomcat-$tver/lib/*.jar ./lib
./bin/version.sh
rm -rf ./temp/apache-tomcat-$tver*

# exit
# docker restart WEBADAPTOR
