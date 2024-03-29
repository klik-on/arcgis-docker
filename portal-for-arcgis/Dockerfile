FROM arcgis/ubuntu-server:latest
ENV TZ Asia/Jakarta
LABEL maintainer="abiyasa@gmail.com"
ENV REFRESHED_AT 2023-09-12
ENV ESRI_VERSION 10.9.1

# Cleanup resources
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Port information: http://server.arcgis.com/en/portal/latest/install/windows/ports-used-by-portal-for-arcgis.htm
EXPOSE 7080 7443

# Probably don't need this for Portal
ADD limits.conf /etc/security/limits.conf

ENV HOME /home/arcgis

# "ADD" knows how to unpack the tar file directly into the docker image.
ADD Portal_for_ArcGIS_Linux_109*.tar.gz /home/arcgis
# ADD Portal_for_ArcGIS_Web_Styles_Linux_109*.tar.gz /home/arcgis

# Add the script that can create the initial admin user and site
# I can't actually run the create_new_site.py here because it will have
# the usual problems (server must be running already)
#ADD create_new_site.py ${HOME}/
# Instead this script will run create_new_site.py..
#ADD start.sh ${HOME}

# Script that changes a string to uppercase, because of HOSTNAME in logfiles
ADD UPPER.py ${HOME}/

# Change owner so that user "arcgis" can remove installer later.
RUN chown -R arcgis:arcgis $HOME

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
#ADD *.prvc /home/arcgis

# Start in the arcgis user's home directory.
WORKDIR ${HOME}
USER arcgis
# ESRI uses LOGNAME
ENV LOGNAME arcgis

# Create a spot where the volatile content can live
RUN mkdir -p portal/usr/arcgisportal

# Change command line prompt
ADD bashrc ./.bashrc

# ENV HOSTNAME portal.arcgis.lan

# It's okay to use the random Docker hostname at this point, but
# we have to fix up the properties filename and we have to use
# a proper FQDN when we configure the host. That means config has
# to wait until we run the container.
#
# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen anyway
#   -l yes            You agree to the License Agreement
#   -a license_file   Use "license_file" to add your license. It can be a .ecp or .prvc file.
#   -d dest_dir       Default is /home/arcgis/arcgis/portal
RUN cd PortalForArcGIS && ./Setup -m silent --verbose -l yes -d $HOME
# RUN cd WebStyles && ./WebStyles-Setup.sh

# We are done with the installer, get rid of it now.
RUN rm -rf PortalForArcGIS
# RUN rm -rf WebStyles

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
ADD portal_lic.json /tmp/
ADD ap.sh $HOME/

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb
ENV PATH $PATH:${HOME}/portal/framework/runtime/pgsql/bin


# HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:7080 || exit 1

CMD cd /home/arcgis && ./portal/startportal.sh  && tail -f portal/usr/arcgisportal/logs/service.log

