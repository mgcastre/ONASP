# Obtain and Prepare Data for Application

# Libraries
require(sf)
require(DBI)
require(RSQLite)
require(htmltools)

# 1. Read SQLite file from Dropbox =============================================

## Download database file and connect
sqlFile <- tempfile(pattern="tp", fileext=".sqlite")
url <- "https://www.dropbox.com/s/mh2zcz3t3q4vxsb/Estibana_v5.1.sqlite?raw=true"
utils::download.file(url=file.path(url), destfile=sqlFile, method="libcurl", mode="wb")
edb <- dbConnect(SQLite(),dbname=sqlFile, synchronous=NULL)
Head_Data <- dbReadTable(edb, "Head_Data")
Head_Points <- dbReadTable(edb, "Head_Points")
dbDisconnect(edb)

## Select well points and data
wells <- filter(Head_Points, Type == "well")
wdata <- Head_Data %>% 
  filter(str_detect(ID, "PM") | str_detect(ID,"MP")) %>% 
  mutate(DTW = -1*DTW, Date = ymd(Date), ID = as.factor(ID))

## Create spatial well points
crs32617 <- CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
wsp <- SpatialPointsDataFrame(
  coords = dplyr::select(wells, X, Y), 
  data   = dplyr::select(wells, ID, Z:LTP),
  proj4string = crs32617)

## transform coordinates for wells
crs4326 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
wsp_ll <- spTransform(wsp, crs4326)

## Add labesl for wells
wsp_ll$New_Name <- 
  paste0('<strong>', wsp_ll$ID, '</strong>',
         '<br/>', 'Distrito: ', wsp_ll$District,
         '<br/>', 'Corregimiento: ', wsp_ll$Township, 
         '<br/>', 'Localidad: ', wsp_ll$Location) %>% 
  lapply(htmltools::HTML)

# 2. Download GeoJSON files from Dropbox =======================================

## Downloading files
path1 <- "https://www.dropbox.com/s/u2t24dixy70y2by/geology.geojson?dl=1"
path2 <- "https://www.dropbox.com/s/hw50i52n6s4rm3a/mainRivers.geojson?dl=1"
path3 <- "https://www.dropbox.com/s/2xezcuqqyvui3y0/watersheds.geojson?dl=1"
geology <- st_read(path1, drivers="GeoJSON", quiet=TRUE)
mainRivers <- st_read(path2, drivers="GeoJSON", quiet=TRUE)
watersheds <- st_read(path3, drivers="GeoJSON", quiet=TRUE)

## Adding labels for geology layer
geology$New_Name <- 
  paste0('<strong>', geology_ll$SIMBOLO, '</strong>',
         '<br/>', 'Formas: ', geology_ll$FORMAS,
         '<br/>', 'Grupo: ', geology_ll$GRUPO, 
         '<br/>', 'Formacion: ', geology_ll$FORMACION) %>% 
  lapply(htmltools::HTML)
