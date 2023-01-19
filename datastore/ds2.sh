# docker cp ds.sh datastore:/tmp/
cd ${HOME}/datastore/tools
./configuredatastore.sh SERVER.WEBGIS.LOKAL siteadmin ipsdh2022 \
   ${HOME}/datastore/usr/arcgisdatastore --stores relational,tileCache
./describedatastore.sh 

# unreg
# cd ${HOME}/datastore/tools
# ./unregisterdatastore.sh --stores relational,tileCache
