# FROM kartoza/postgis:15.8
FROM postgis/postgis:15-3.4

MAINTAINER Klik.On <abiyasa@gmail.com>
LABEL version="POSTGRESQL for ArcGIS-POSTGIS" \
          author="Klik.On" \
          description="This is for Klik.On"

COPY ./lib/* /usr/lib/postgresql/15/lib

# Update apt-get and instal some tools
RUN apt update && apt upgrade -yq
RUN apt install -yq tzdata
# Set Timezone
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

