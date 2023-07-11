# buat volume docker =>  mkdir -p data/{config-store,directories,logs,sysgen}
# docker cp patch DATASTORE:/tmp

# cara update os
# docker exec -it -u root DATASTORE /bin/bash
# apt update && apt upgrade

echo My hostname is $HOSTNAME

for patchfile in *.tar; do
   tar -xvf $patchfile
   rm -rf $patchfile
done

   for patchdir in DS-1091-P-* ; do
        $patchdir/applypatch -s -datastore
	rm -rf $patchdir
done

# DS-1091-P-806/applypatch-s -datastore /home/arcgis/datastore
