# untuk update patch dan login
# https://portal.arcgis.lan:7443/arcgis/portaladmin/system/properties/update
# {"WebContextURL":"https://agsipsdh.menlhk.go.id/portal"}

HOSTNAME=`hostname`
# ESRI likes its hostname to be ALL UPPER CASE! but SOMETIMES not
# UPPERHOST=`python3 UPPER.py "$HOSTNAME"`

# Clean out the content folder so we don't go into "upgrade" mode.
echo "Clearing out previous data"
cd portal/usr/arcgisportal/ && \
  rm -rf content/* db dsdata index pgsql* sql logs/${HOSTNAME}/portal/*.l*

cd ${HOME}/portal/tools/createportal
 ./createportal.sh -fn JIG -ln LHK -u portaladmin -p ipsdh2022 \
 -e webgis@menlhk.go.id -qi 1 -qa JKT -d ${HOME}/portal/usr/arcgisportal/content -lf /tmp/portal_lic.json

# setelah running
# we deleted all the logs up above, yikes, what a hack
# export LOGFILE="${HOME}/portal/usr/arcgisportal/logs/${UPPERHOST}/portal/*.log"
# echo "Logfile is $LOGFILE"
