# buat volume docker =>  mkdir -p data/{config-store,directories,logs,sysgen}
# docker cp patch SERVER:/tmp

for patchfile in *.tar; do
   tar -xvf $patchfile
   rm -rf $patchfile
done

   for patchdir in S-1091-P-* ; do
        $patchdir/applypatch -s -server
	rm -rf $patchdir
done

# DS-1091-P-806/applypatch-s -datastore /home/arcgis/datastore
