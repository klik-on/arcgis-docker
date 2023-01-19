# Start a new server container
docker run -it --rm --name=server --net-alias=arcgis.lan  \
    --hostname=server.arcgis.lan --net=arcgis \
    -p 6080:6080 -p 6443:6443 \
    -v `pwd`/data/config-store:/home/arcgis/server/usr/config-store \
    -v `pwd`/data/directories:/home/arcgis/server/usr/directories \
    -v `pwd`/data/logs:/home/arcgis/server/usr/logs \
    -v `pwd`/data/sysgen:/home/arcgis/server/framework/runtime/.wine/drive_c/Program\ Files/ESRI/License10.9.1/sysgen \
    arcgis/server:10.9.1 bash
