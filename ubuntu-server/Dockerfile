FROM ubuntu:jammy
ENV RELEASE=jammy
# "jammy" is currently the latest LTS (Long Term Support) release.
RUN apt-get update && apt-get -yq install apt-utils locales tzdata openssh-client

# Set up the locale. 
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Set Timezone
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# The gettext package is needed to install ArcGIS Server,
# Others can be convenient
RUN apt-get -yq install gettext less vim net-tools unzip

# Some useful tools; can't go far without python.
RUN apt-get -yq install bind9-host iputils-ping wget python3 python3-pip 
RUN ln -s /etc/alternatives/python /usr/bin/python &&\
    ln -s /usr/bin/python3 /etc/alternatives/python

RUN pip install --upgrade pip && pip install requests
RUN pip install python-dateutil

# -- This is for ArcGIS 10.9
# Add the repository for Postgres 12 (this additional repo is not needed with Focal)
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" >> /etc/apt/sources.list
#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
# RUN apt-get update && apt-get install -y postgresql-client-12

# -- ODBC MSSQL
# RUN apt-get -y install gpg curl apt-transport-https unixodbc-dev
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update
# RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated msodbcsql17
# RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated mssql-tools
# RUN apt-get upgrade

# This will make the system work better and eliminate warnings from the temporal store checks
# COPY arcgis.conf /etc/sysctl.d/
RUN echo "vm.max_map_count = 262144\nvm.swappiness = 1" >> /etc/sysctl.conf

# These are needed by Portal For ArcGIS
RUN apt-get -yq install libice6 libsm6 libxtst6 libxrender1 dos2unix

# Create the user/group who will run ArcGIS services
# I set them to my own UID/GID so that the VOLUMES I create will be read/write
RUN groupadd -g 1000 arcgis && useradd -m -r arcgis -g arcgis -u 1000
ENV HOME /home/arcgis

WORKDIR ${HOME}

# Note the user is still set to root here, we want this so that
# containers that pull from this one still have root when they start.

# Cleanup resources
RUN apt-get update && apt-get -yq upgrade
RUN apt-get -yq --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
