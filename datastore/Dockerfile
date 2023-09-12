FROM arcgis/ubuntu-server:latest
ENV TZ Asia/Jakarta

LABEL maintainer="abiyasa@gmail.com"
ENV REFRESHED_AT 2022-10-25
ENV ESRI_VERSION 10.9.1

# Cleanup resources
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 2443
# If you are not using a Docker network to connect containers
# you might want to expose these ports, too.
# EXPOSE 9876 29080 29081 9220 9320

# Refer to ESRI docs; this expands limits for user arcgis.
# ADD limits.conf /etc/security/limits.conf
RUN echo "arcgis soft nofile 65535\narcgis hard nofile 65535\narcgis soft nproc 25059\narcgis hard nproc 25059" >> /etc/security/limits.conf

# "ADD" knows how to unpack the tar file directly into the docker image.
ADD ArcGIS_DataStore_Linux_109*.tar.gz ${HOME}
# Change owner so that arcgis can rm later.
RUN chown -R arcgis:arcgis ${HOME}

USER arcgis
WORKDIR ${HOME}

RUN cd ArcGISDataStore_Linux && ./Setup -m silent --verbose -l yes -d /home

RUN rm -rf ${HOME}/ArcGISDataStore_Linux
ENV DS_DATADIR ${HOME}/datastore/usr/arcgisdatastore
ENV PGDATA ${HOME}/data/pgdata

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb
ENV PATH $PATH:${HOME}/datastore/framework/runtime/pgsql/bin

# Change command line prompt
ADD bashrc .bashrc
ADD ds.sh ds.sh
ADD ds2.sh ds2.sh
ADD UPPER.py UPPER.py

# Hmmm I wonder if I should check the HTTP or HTTPS service??
# HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:6080 || exit 1

# Command that will be run by default when you do "docker run" 
CMD ./datastore/startdatastore.sh && tail -f ./datastore/framework/etc/service_error.log

