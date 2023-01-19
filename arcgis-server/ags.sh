# docker cp ags.sh server:/tmp/
echo My hostname is $HOSTNAME
NEWPROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"
PROPERTIES=".ESRI.properties.*.${ESRI_VERSION}"
if ! [ -f "$NEWPROPERTIES" ] && [ -f "$PROPERTIES" ]; then
    echo "Linked $PROPERTIES."
    ln -s $PROPERTIES $NEWPROPERTIES
fi

# Do that brute force thing, remove the directory contents.
CONFIGDIR="./server/usr/config-store"
if [ -e ${CONFIGDIR}/.site ]; then
    echo "Removing previous site configuration files."
    rm -rf ${CONFIGDIR}/* ${CONFIGDIR}/.site
fi


cd ${HOME}/server/tools
./authorizeSoftware -f ${HOME}/Server_Ent_Adv.prvc -e abiyasa@gmail.com

## Createsite
cd ${HOME}/server/tools/createsite
./createsite.sh -u siteadmin -p ipsdh2022 -d ${HOME}/server/usr/directories -c ${HOME}/server/usr/config-store

