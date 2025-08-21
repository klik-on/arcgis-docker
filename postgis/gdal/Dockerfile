# Base OS
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GDAL_VERSION=3.11.3

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    wget \
    git \
    python3 \
    python3-pip \
    libsqlite3-dev \
    libproj-dev \
    libgeos-dev \
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libxml2-dev \
    libssl-dev \
    libpq-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Download & build GDAL from source
WORKDIR /opt
RUN wget https://download.osgeo.org/gdal/CURRENT/gdal-${GDAL_VERSION}.tar.gz && \
    tar -xzf gdal-${GDAL_VERSION}.tar.gz && \
    rm gdal-${GDAL_VERSION}.tar.gz

WORKDIR /opt/gdal-${GDAL_VERSION}/build
RUN cmake .. -DWITH_PG=ON && \
    cmake --build . -- -j$(nproc) && \
    cmake --build . --target install && \
    ldconfig

# Install Python bindings (GDAL + pip)
RUN pip3 install GDAL==${GDAL_VERSION}

# Cek driver PostgreSQL dan FileGDB
RUN ogrinfo --formats | grep -Ei "gdb|postgresql" || true

# Default working directory (shared with Docker Compose)
WORKDIR /data
