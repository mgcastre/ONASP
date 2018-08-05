library(shiny)
library(googlesheets)
library(leaflet)
library(sp)
library(lubridate)
library(dplyr)
library(plotly)
library(tidyr)
library(shinyBS)
library(shinythemes)

#####################################################
# Obtain data and clean
#####################################################

# get googlesheet key
key <- extract_key_from_url("https://docs.google.com/spreadsheets/d/1YyoLssme-PZBF_C2Ko30E0GgLE3x92Z31iz04a0ZR9M/edit#gid=1936918230")

# "register" the sheet: create googlesheet object with sheet metadata
# document must be "Published to the Web"
# see: https://github.com/jennybc/googlesheets/issues/272
obj <- gs_key(key)

# Use the googlesheet object to extract:
ll <- gs_read(obj, ws = "Puntos Monitoreo") # lat long: after a transformation 
np <- gs_read(obj, ws = "Niveles Pozos")    # groundwater head 
nr <- gs_read(obj, ws = "Niveles Rios")     # river heads

# replace all "#N/A" with NA
# in the future, techs to leave missing feilds blank to avoid extra dependency
library(naniar)
ll <- replace_with_na_all(ll, ~.x %in% "#N/A")
np <- replace_with_na_all(np, ~.x %in% "#N/A")
nr <- replace_with_na_all(nr, ~.x %in% "#N/A")

#####################################################
# Create Spatial Objects
#####################################################

# create spatial points data frames for *locations* of niveles puntos y rios
np_coords <- ll[grepl("PM", ll$ID),  c("East","North")] # puntos coords
np_data   <- ll[grepl("PM", ll$ID),  -c(2,3)] # puntos data

nr_coords <- ll[!grepl("PM", ll$ID), c("East","North")] # rios coords
nr_data   <- ll[!grepl("PM", ll$ID), -c(2,3)] # rios data

# puntos spdf
np_sp <- SpatialPointsDataFrame(
  coords = np_coords, 
  data   = np_data,
  proj4string = CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

# rios spdf
nr_sp <- SpatialPointsDataFrame(
  coords = nr_coords, 
  data   = nr_data,
  proj4string = CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

# transform to lat lon
np_sp <- spTransform(np_sp, "+proj=longlat +ellps=WGS84 +datum=WGS84")
nr_sp <- spTransform(nr_sp, "+proj=longlat +ellps=WGS84 +datum=WGS84")

#####################################################
# Clean hydrograph data for plots
#####################################################

# convert character date strings to date objects with lubridate
np$`Fecha (d/m/a)` <- dmy(np$`Fecha (d/m/a)`) # pozos
nr$`Fecha (d/m/a)` <- dmy(nr$`Fecha (d/m/a)`) # rios

# change Fecha -> Date, and Nivel -> value so it's compatiable with code
# Can go back later and fix these
nr <- nr %>% rename(Date = `Fecha (d/m/a)`)
nr <- nr %>% rename(value = `Nivel (m)`)
np <- np %>% rename(Date = `Fecha (d/m/a)`)
np <- np %>% rename(value = `Nivel (m)`)

# convert character values into numeric type
nr$value <- as.numeric(nr$value)
np$value <- as.numeric(np$value)


# fix duplicated entries 
# convert from long to wide and overwrite on google sheet
nr <- nr[!duplicated(nr), ] 

# repeat for pozos
np <- np[!duplicated(np), ] 


#####################################################
# Set of np and nr WITH COORDINATES
#####################################################
np <- np %>% filter(ID %in% np_sp$ID)
nr <- nr %>% filter(ID %in% nr_sp$ID)


#####################################################
# Color Palette Data
#####################################################

# we want to divide the gray color scale for the map of all the well hydrographs
# There are 100 grayscale colors "gray0" through "gray100"
n_pozos <- np$ID %>% unique() %>% length()
pozos_pal <- paste0("gray", seq(0, (n_pozos - 1) * 3, 3))


#####################################################
# Misc. Items
#####################################################

caption <- "These monitoring wells reflect the water table elevation in Panama's xyz basin. For more information on research by abc, please visit"


