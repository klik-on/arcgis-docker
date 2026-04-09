#!/bin/bash
# Menggunakan hostname dari environment atau default ke dbgis
# docker exec -it WEBADAPTOR /usr/local/bin/ap_wa.sh

WA_HOSTNAME=${HOSTNAME:-portal.domain.go.id}
/arcgis/webadaptor10.9.1/java/tools/configurewebadaptor.sh -m portal \
 -w https://${WA_HOSTNAME}/portal/webadaptor \
 -g https://portal.agis.lokal:7443 -u portaladmin -p test2026

