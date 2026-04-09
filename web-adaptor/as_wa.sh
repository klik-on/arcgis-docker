#!/bin/bash
# Menggunakan hostname dari environment atau default ke dbgis
# docker exec -it WEBADAPTOR /usr/local/bin/ap_wa.sh

WA_HOSTNAME=${HOSTNAME:-server.domain.go.id}
/arcgis/webadaptor10.9.1/java/tools/configurewebadaptor.sh -m server \
 -w https://${WA_HOSTNAME}/server/webadaptor \
 -g https://server.agis.lokalL:6443 \
 -u siteadmin -p test2026 -a true
