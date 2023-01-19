# Our hostname is different than when we built this container image,
# fix up the name of our properties file
echo My hostname is $HOSTNAME
NEWPROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"
PROPERTIES=".ESRI.properties.*.${ESRI_VERSION}"
if ! [ -f "$NEWPROPERTIES" ] && [ -f "$PROPERTIES" ]; then
    echo "Linked $PROPERTIES."
    ln -s $PROPERTIES $NEWPROPERTIES
fi
