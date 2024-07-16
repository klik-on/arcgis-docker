Fix Update 
Data Store$ cd ${HOME}
Data Store$ cp .ESRI.properties.20bc5d498e20.10.9.1 .ESRI.properties.datastore.arcgis.lan.10.9.1

# Datastore

Docker container for the ESRI ArcGIS Enterprise Data Store

I don't have a license for the temporal data so I don't address it,

## Build 

    docker build -t arcgis/datastore:10.9.1 .

## Ports

### Web access port

HTTPSweb management: port 2443

### Data store ports

Relational data store: port 9876.

Tile cache data stores: ports 29080 and 29081.

Spatiotemporal big data stores: ports 9220 and 9320.

## Content directory

/home/arcgis/datastore/usr/arcgisdatastore

## Data store types

*Relational* Required data store type for ArcGIS Enterprise, used by
hosted feature layers, spatial analysis tools, and Insights
for ArcGIS

*Tile Cache* Stores tile caches for hosted scene layers

*Spatiotemporal* Archives real-time data for GeoEvent Server, and stores
output from GeoAnalytics Server tools

## Connection problem?

On my first attempt to connect to the server I got this error:
"Attempt to configure data store failed.. Extended error message: The
specified GIS Server site already has a managed data store."
 
I had to open the ArcGIS Server Manager (on port 6443) go to "Site"
tab select "Data Store" in the sidebar and select and delete the data
store there

## Backends

Datastore includes Postgresql, so I don't really care about anything else.
I removed the notes I used to have here about SQL Server.

From Desktop run the Create Spatial Type tool

From ArcCatalog you can create a connection to a PostgreSQL database,
then you can "Enable Enterprise Geodatabase". This will ask for an authorization file.
It's looking for a keycodes file, not a PRVC file.

## Changes

I used to try to configure the datastore in the start.sh script,
and also to federate.

That meant the datastore had to wait for the server to start.

It also meant I could not use the unconfigured datastore to restore a backup from a working datastore on
another machine to test the restore process. That's what I am doing today.

Hence all that is commented out in start.sh now.
You have to do those steps manually now.


## vi .env untuk docker compose
AGE_USER=siteadmin
AGE_PASSWORD=TEST2022

AGE_SERVER=server.arcgis.lan
AGE_PORTAL=portal.arcgis.lan

