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

# Render Leaflet Interactive Map
leaflet(wsp_ll) %>%
  addTiles(group = "OSM") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
  addProviderTiles(providers$Esri.WorldShadedRelief, group = "ESRI Relief") %>%
  addMarkers(popup = ~New_Name) %>%
  addPolygons(data = geology_ll, group = "Geología",
              popup = ~geology_ll$New_Name,
              stroke = TRUE, color = "black", opacity = 1,
              fill = TRUE, fillOpacity = 0.5, weight = 0.5,
              fillColor = ~colorFactor("YlOrBr", formas)(formas),
              highlightOptions = highlightOptions(color = "white", weight = 1.5, bringToFront = FALSE)) %>%
  addPolygons(data = watersheds_ll, group = "Cuencas",
              stroke = TRUE, fill = FALSE, opacity = 1,
              color = "navy", weight = 3) %>%
  addPolylines(data = rivers_ll, group = "Ríos",
               color = "dodgerblue", weight = 2,
               opacity = 1, popup = ~rivers_ll$label,
               highlightOptions = highlightOptions(color = "cyan", weight = 2.5)) %>%
  setView(lng = -80.5, lat = 8.6, zoom = 7.5) %>%
  addLayersControl(baseGroups = c("OSM", "Toner Lite", "ESRI Imagery", "ESRI Relief"),
                   overlayGroups = c("Cuencas","Geología","Ríos"),
                   options = layersControlOptions(collapsed = FALSE))

# Create color palette
nw <- wells$ID %>% unique() %>% length()
wells_pal <- colorRampPalette(brewer.pal(12,"Dark2"))(nw)

# ggplot
figure <- wdata %>% 
  highlight_key(~ID) %>% 
  ggplot(mapping = aes(x = Date, y = DTW)) + 
  ggtitle("Niveles Piezométricos en Pozos de Observación") +
  geom_line(mapping = aes(color = ID)) +
  geom_point(mapping = aes(color = ID), size = 1.5) +
  geom_smooth(color = "grey45") + theme_light() +
  scale_colour_manual(values = wells_pal) +
  scale_x_date(name = "Fecha", date_breaks = "3 months", date_labels = "%b %Y") +
  labs(y = "Profundidad al Nivel Estático (m)", x = "Fecha") +
  theme(axis.text.x = element_text(angle = 45))

# plotly
ggplotly(figure) %>% 
  group_by(ID) %>%
  highlight(on = "plotly_hover", 
            off = "plotly_doubleclick",
            opacityDim = 0.2)