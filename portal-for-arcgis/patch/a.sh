# buat volume docker =>  mkdir -p data/{config-store,directories,logs,sysgen}
# docker cp patch PORTAL:/tmp

for patchfile in *.tar; do
   tar -xvf $patchfile
   rm -rf $patchfile
done

   for patchdir in PFA-1091-P-*; do
        $patchdir/applypatch -s -portal
	rm -rf $patchdir
done

# DS-1091-P-806/applypatch-s -datastore /home/arcgis/datastore
