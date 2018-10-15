# Required Libraries
library(shiny)
library(googlesheets)
library(leaflet)
library(sp)
library(stringr)
library(lubridate)
library(tidyverse)
library(plotly)
library(shinyBS)
library(shinythemes)
library(naniar)

#####################################################
# Obtain data and clean
#####################################################

# Get googlesheet key
key <- extract_key_from_url("https://docs.google.com/spreadsheets/d/1YyoLssme-PZBF_C2Ko30E0GgLE3x92Z31iz04a0ZR9M/edit#gid=1936918230")

# "register" the sheet: create googlesheet object with sheet metadata
# document must be "Published to the Web"
# see: https://github.com/jennybc/googlesheets/issues/272
obj <- gs_key(key)

# Use the googlesheet object to extract:
ll <- gs_read(obj, ws = "Puntos Monitoreo") # lat long: after a transformation 
np <- gs_read(obj, ws = "Niveles Pozos")    # groundwater head 
nr <- gs_read(obj, ws = "Niveles Rios")     # river heads

# Replace all "#N/A" with NA
# in the future, techs to leave missing feilds blank to avoid extra dependency
ll <- replace_with_na_all(ll, ~.x %in% "#N/A")
np <- replace_with_na_all(np, ~.x %in% "#N/A")
nr <- replace_with_na_all(nr, ~.x %in% "#N/A")

# Change column names
colnames(np) <- c("ID","Date","Value","Comentario")
colnames(nr) <- c("ID","Date","Value","Comentario")

#####################################################
# Create Spatial Objects
#####################################################

# Define coordinate reference system
crsdef <- CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

# Create spatial points data frames for *locations* of niveles pozos y rios
## pozos (ID = PM, MP)
np_coords <- ll %>% filter(str_detect(ID, "PM") | str_detect(ID,"MP")) %>% select(East, North) # pozos coords
np_data   <- ll %>% filter(str_detect(ID, "PM") | str_detect(ID,"MP")) %>% select(-East, -North) # pozos data
## rios (ID = HR, LS)
nr_coords <- ll %>% filter(str_detect(ID, "HR") | str_detect(ID,"LS")) %>% select(East, North) # rios coords
nr_data   <- ll %>% filter(str_detect(ID, "HR") | str_detect(ID,"LS")) %>% select(-East, -North) # rios data

# Pozos spdf
np_sp <- SpatialPointsDataFrame(
  coords = np_coords, 
  data   = np_data,
  proj4string = crsdef)

# Rios spdf
nr_sp <- SpatialPointsDataFrame(
  coords = nr_coords, 
  data   = nr_data,
  proj4string = crsdef)

# Transform to lat lon
np_sp <- spTransform(np_sp, "+proj=longlat +ellps=WGS84 +datum=WGS84")
nr_sp <- spTransform(nr_sp, "+proj=longlat +ellps=WGS84 +datum=WGS84")

#####################################################
# Clean hydrograph data for plots
#####################################################

# Convert character date strings to date objects with lubridate
np$Date <- dmy(np$Date) # pozos
nr$Date <- dmy(nr$Date) # rios

# Convert character values into numeric type
nr$Value <- as.numeric(nr$Value)
np$Value <- as.numeric(np$Value)

# Fix duplicated entries 
# convert from long to wide and overwrite on google sheet
nr <- nr[!duplicated(nr), ] 
np <- np[!duplicated(np), ] 


#####################################################
# Set of np and nr WITH COORDINATES
#####################################################
# np <- np %>% filter(ID %in% np_sp$ID)
# nr <- nr %>% filter(ID %in% nr_sp$ID)


#####################################################
# Color Palette Data
#####################################################

# We want to divide the gray color scale for the map of all the well hydrographs
# There are 100 grayscale colors "gray0" through "gray100"
n_pozos <- np$ID %>% unique() %>% length()
pozos_pal <- paste0("gray", seq(0, (n_pozos - 1) * 3, 3))


#####################################################
# Misc. Items
#####################################################

caption <- "These monitoring wells reflect the water table elevation in Panama's xyz basin. For more information on research by abc, please visit"


