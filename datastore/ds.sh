# docker cp ds.sh datastore:/tmp/
# UPPERHOST=`python3 UPPER.py "$HOSTNAME"`

rm -f ${HOME}/datastore/usr/logs/${UPPERHOST}/server/*.l*

export LOGFILE="${HOME}/datastore/usr/logs/$UPPERHOST/server/*.log"
echo "Logfile is $LOGFILE"   

echo -n "Is the Datastore server \"${HOSTNAME}\" ready? "
curl --retry 15 -sS --insecure "https://${HOSTNAME}:2443/" > /tmp/dshttp
if [ $? != 0 ]; then
    echo "Datastore missing!. $? Maybe it's slow to start?"
    exit 1
fi
echo "Lanjut"


cd ${HOME}/datastore/tools
./configuredatastore.sh SERVER.WEBGIS.LOKAL siteadmin ipsdh2022 \
  ${HOME}/datastore/usr/arcgisdatastore --stores relational,tileCache
./describedatastore.sh

exit 0
