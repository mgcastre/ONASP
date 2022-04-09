##################################################
# Reorganize some data
##################################################
library(here)
library(readr)
library(tidyr)

# load up data in global.R first

# There are duplicated entries! We must remove these in order to spread, gather, and plot

# convert from long to wide and overwrite on google sheet
nr <- nr[!duplicated(nr), ] %>% 
  spread(ID, `Nivel (m)`)
# move comentario to end
nr <- cbind.data.frame(nr[, -2], nr[, 2])
# save file to copy paste if we stat reporting in wide format
readr::write_csv(nr, "nr_wide.csv")

# repeat for pozos
np <- np[!duplicated(np), ] %>% 
  spread(ID, `Nivel (m)`)
# move comentario to end
np <- cbind.data.frame(np[, -2], np[, 2])
# save file to copy paste if we stat reporting in wide format
readr::write_csv(np, "np_wide.csv")


# Render Leaflet Interactive Map
leaflet(wsp_ll) %>%
  addTiles(group = "OSM") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
  addProviderTiles(providers$Esri.WorldShadedRelief, group = "ESRI Relief") %>%
  addMarkers(popup = ~New_Name) %>%
  setView(lng = -80.5, lat = 8.6, zoom = 7.5) %>%
  addLayersControl(baseGroups = c("OSM", "Toner Lite", "ESRI Imagery", "ESRI Relief"),
                   options = layersControlOptions(collapsed = TRUE))