# Obtain and Prepare Data for Application

# Libraries
require(DBI)
require(RSQLite)
require(htmltools)
require(lubridate)
require(stringr)
require(dplyr)
require(rgdal)

# 1. Read SQLite file from Dropbox =============================================

## Download database file and connect
sqlFile <- tempfile(pattern="tp", fileext=".sqlite")
url <- "https://www.dropbox.com/s/mh2zcz3t3q4vxsb/Estibana_v5.1.sqlite?raw=true"
utils::download.file(url=file.path(url), destfile=sqlFile, method="libcurl", mode="wb", quiet=TRUE)
edb <- dbConnect(SQLite(),dbname=sqlFile, synchronous=NULL)
Head_Data <- dbReadTable(edb, "Head_Data")
Head_Points <- dbReadTable(edb, "Head_Points")
rglocs <- dbReadTable(edb, "Precipitation_Locations")
rgdata <- dbReadTable(edb, "Precipitation_Measurements")
dbDisconnect(edb)

## Select Well Points
wells <- filter(Head_Points, Type == "well") %>% mutate(ID = as.factor(ID))

## Select GW Data from Wells
wdata <- Head_Data %>% 
  filter(str_detect(ID, "PM") | str_detect(ID,"MP")) %>% 
  mutate(DTW = -1*DTW, Date = ymd(Date), ID = as.factor(ID))

## Generate Monthly Precipitation Measurements
rgdata_monthly <- rgdata %>% 
  mutate(Month = month(Date), 
         Year = year(Date),
         ID = as.factor(ID)) %>% 
  group_by(ID, Year, Month) %>% 
  summarize(Value = sum(Value)) %>% 
  ungroup() %>% 
  mutate(Date = ymd(paste(Year,Month,"01",sep="-")),
         Unit = "mm/month") %>% 
  dplyr::select(ID, Date, Value, Unit)

## Define coordinate reference systems
crs32617 <- CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
crs4326 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")

## Create Spatial Well Points
wsp <- SpatialPointsDataFrame(
  coords = dplyr::select(wells, X, Y), 
  data   = dplyr::select(wells, ID, Z:LTP),
  proj4string = crs32617)

## Create Spatial Rain Gages
rgsp <- SpatialPointsDataFrame(
  coords = dplyr::select(rglocs, X, Y), 
  data   = dplyr::select(rglocs, ID, LoggerID, Province:Project),
  proj4string = crs32617)

## Transform Coordinates to Lat Lon
wsp_ll <- spTransform(wsp, crs4326)
rgsp_ll <- spTransform(rgsp, crs4326)

## Add Labels for Wells
wsp_ll$New_Name <- 
  paste0('<strong>', wsp_ll$ID, '</strong>',
         '<br/>', 'District: ', wsp_ll$District,
         '<br/>', 'Township: ', wsp_ll$Township, 
         '<br/>', 'Location: ', wsp_ll$Location,
         '<br/>', 'Depth: ', wsp_ll$Depth, ' m') %>% 
  lapply(htmltools::HTML)

## Add Labels for Rain Gages
rgsp_ll$New_Name <- 
  paste0('<strong>', rgsp_ll$ID, '</strong>',
         '<br/>', 'District: ', rgsp_ll$District,
         '<br/>', 'Townsip: ', rgsp_ll$Township, 
         '<br/>', 'Location: ', rgsp_ll$Location) %>% 
  lapply(htmltools::HTML)

# 2. Download FGB files from Dropbox ===========================================

## Create function
downloadFGB <- function(url) {
  fgbFile <- tempfile(pattern="geo", fileext=".fgb")
  utils::download.file(url=file.path(url), destfile=fgbFile, method="libcurl", mode="wb", quiet=TRUE)
  return(fgbFile)
}

## Download files
watersheds_ll <- downloadFGB("https://www.dropbox.com/s/hfdapileypxz1da/watersheds.fgb?raw=true")
mainRivers_ll <- downloadFGB("https://www.dropbox.com/s/vf6neqavcxogdne/mainRivers.fgb?raw=true")
geology_ll <- downloadFGB("https://www.dropbox.com/s/d3twn7nlh7e4r20/geology.fgb?raw=true")

