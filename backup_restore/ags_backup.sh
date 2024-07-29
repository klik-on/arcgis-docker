docker container commit -a "PORTAL" -m "Update PORTAL" PORTAL ags_portal_1091
docker save -o ags_portal_1091.tar ags_portal_1091

docker container commit -a "SERVER" -m "Update SERVER" SERVER ags_server_1091
docker save -o ags_server_1091.tar ags_server_1091

docker container commit -a "DATASTORE" -m "Update DATASTORE" DATASTORE ags_datastore_1091
docker save -o ags_datastore_1091.tar ags_datastore_1091

docker container commit -a "WEBADAPTOR" -m "Update WEBADAPTOR" WEBADAPTOR ags_webadaptor_1091
docker save -o ags_webadaptor_1091.tar ags_webadaptor_1091
