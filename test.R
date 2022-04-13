# Test to read a database from Dropbox
library(DBI)
library(RSQLite)
sqlFile <- tempfile(pattern="tp", fileext=".sqlite")
url <- "https://www.dropbox.com/s/mh2zcz3t3q4vxsb/Estibana_v5.1.sqlite?raw=true"
utils::download.file(url=file.path(url), destfile=sqlFile, method="libcurl", mode="wb")
edb <- dbConnect(SQLite(),dbname=sqlFile, synchronous=NULL)
dbDisconnect(edb)

# Test to download shapefiles from ArcGIS API (Smithsonian)
library(sf)
library(leaflet)
path1 <- "https://services2.arcgis.com/HRY6x8qt5qjGnAA9/arcgis/rest/services/Panama_Hydrography/FeatureServer/2/query?where=1%3D1&outFields=CAUDAL,CUENCA_N,NOMBRE,AFLUENTE,ORDEN,LABEL,TIPO&outSR=4326&f=geojson"
path2 <- "https://services2.arcgis.com/HRY6x8qt5qjGnAA9/arcgis/rest/services/Geologia_Panama/FeatureServer/13/query?where=1%3D1&outFields=SIMBOLO,GRUPO,FORMACION,FORMAS,LEYENDA,CATEGORIA&outSR=4326&f=geojson"
path3 <- "https://services2.arcgis.com/HRY6x8qt5qjGnAA9/arcgis/rest/services/Panama_Hydrography/FeatureServer/1/query?where=1%3D1&outFields=CATEGORIA,WSD_ID,MAIN_RIVER,AREA_HA,VERTIENTE&outSR=4326&f=geojson"
geology <- st_read(path2, drivers="GeoJSON")
watersheds <- st_read(path3, drivers="GeoJSON")
mainRivers <- st_read(path1, drivers="GeoJSON")
leaflet(wsp_ll) %>%
  addTiles(group = "OSM") %>%
  addPolylines(data = mainRivers, group = "Ríos",
               color = "dodgerblue", weight = 2,
               # opacity = 1, popup = ~rivers_ll$label,
               highlightOptions = highlightOptions(color = "cyan", weight = 2.5)) %>%
  setView(lng = -80.5, lat = 8.6, zoom = 7.5)
