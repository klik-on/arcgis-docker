for patchfile in *_1091.tar; do
    docker load < $patchfile
done
