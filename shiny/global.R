# Global for Shinny App
# M.G. Castrellon
# 2/23/2022

# Read shapefiles from database
shpDB <- "../data/PanamaShapefiles.sqlite"
rivers <- readOGR(dsn=shpDB, layer="rivers_main_2011", verbose=F, use_iconv=T, encoding="UTF-8")
geology <- readOGR(dsn=shpDB, layer="geologic_formations_1990", verbose=F, use_iconv=T, encoding="UTF-8")
watersheds <- readOGR(dsn=shpDB, layer="watersheds_2012", verbose=F, use_iconv=T, encoding="UTF-8")

# Open database connection and read tables
objDB <- dbConnect(drv=SQLite(), dbname="../data/Estibana_v5.1.sqlite")
Head_Data <- dbReadTable(objDB, "Head_Data")
Head_Points <- dbReadTable(objDB, "Head_Points")
dbDisconnect(objDB)

# Select Well Points
wells <- filter(Head_Points, Type == "well") %>% mutate(ID = as.factor(ID))

# Select GW Data from Wells
wdata <- Head_Data %>% 
  filter(str_detect(ID, "PM") | str_detect(ID,"MP")) %>% 
  mutate(DTW = -1*DTW, Date = ymd(Date), ID = as.factor(ID))

# Combine GW Data with Info for Wells

# Define coordinate reference systems
crs32617 <- CRS("+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
crs4326 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")

# Create Spatial Well Points
wsp <- SpatialPointsDataFrame(
  coords = dplyr::select(wells, X, Y), 
  data   = dplyr::select(wells, ID, Z:LTP),
  proj4string = crs32617)

# Transform Coordinates to Lat Lon
wsp_ll <- spTransform(wsp, crs4326)
rivers_ll <- spTransform(rivers, crs4326)
geology_ll <- spTransform(geology, crs4326)
watersheds_ll <- spTransform(watersheds, crs4326)

# Add Labels for Wells
wsp_ll$New_Name <- 
  paste0('<strong>', wsp_ll$ID, '</strong>',
         '<br/>', 'Distrito: ', wsp_ll$District,
         '<br/>', 'Corregimiento: ', wsp_ll$Township, 
         '<br/>', 'Localidad: ', wsp_ll$Location) %>% 
  lapply(htmltools::HTML)

# Add Labels for Geology
geology_ll$New_Name <- 
  paste0('<strong>', geology_ll$simbolo, '</strong>',
         '<br/>', 'Formas: ', geology_ll$formas,
         '<br/>', 'Grupo: ', geology_ll$grupo, 
         '<br/>', 'Formacion: ', geology_ll$formacion) %>% 
  lapply(htmltools::HTML)

# Define Function to Plot Wells
plotWells <- function(data_table, w_name){
  ## Creating Color Pallette
  nw <- data_table$ID %>% unique() %>% length()
  wells_pal <- colorRampPalette(brewer.pal(12,w_name))(nw)
  ## Plotting
  figure <- ggplot(data = data_table, mapping = aes(x = Date, y = DTW)) + 
    geom_line(mapping = aes(color = ID), linetype = "dashed") +
    geom_point(mapping = aes(color = ID), shape = 15) +
    geom_smooth(color = "grey45") + theme_light() + 
    scale_colour_manual(values = wells_pal) +
    scale_x_date(name = "Fecha", date_breaks = "3 months", date_labels = "%b %Y") +
    labs(y = "Profundidad al Nivel Estático (m)", x = "Fecha")
  return(ggplotly(figure))
}