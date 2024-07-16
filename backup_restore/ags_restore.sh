for patchfile in ags_*.tar; do
    docker load < $patchfile
done
