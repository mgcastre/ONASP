shinyServer(function(input, output, session){
  
  # Tab 1: Map ####################################################################################
  
  # when the ID changes, so does the data for the plot
  wselected <- reactive({
    wells %>% filter(ID == input$mw)
  })
  
  # when a ID is chosen in the drop down menu, change the map popup
  observeEvent(input$mw, {
    p1 <- input$Map_marker_click
    p2 <- wells %>% filter(ID==input$mw)
    if(nrow(p2)==0){
      leafletProxy("Map") %>% removeMarker(layerId="Selected")
    } else if(is.null(p1$id) || input$mw != p1$id){
      leafletProxy("Map") %>% 
        setView(lng=p2$lng, lat=p2$lat, input$Map_zoom) %>% 
        addCircleMarkers(p2$lng, p2$lat, 
                         radius=10, color="black", fillColor="orange", 
                         fillOpacity=1, opacity=1, stroke=TRUE, 
                         layerId="Selected")
    }
  })
  
  # Leaflet output of wells
  output$Map <- renderLeaflet({
    leaflet(wsp_ll) %>%
      addTiles(group = "OSM") %>%
      # addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
      # addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
      # addProviderTiles(providers$Esri.WorldShadedRelief, group = "ESRI Relief") %>%
      addMarkers(popup = ~New_Name, label = ~ID, layerId = ~ID) %>% 
      setView(lng = -80.5, lat = 8.6, zoom = 7.5)
  })
  
  observeEvent(input$Map_marker_click, {
    p <- input$Map_marker_click
    if(p$id=="Selected"){
      leafletProxy("Map") %>% 
        removeMarker(layerId="Selected")
    } else {
      leafletProxy("Map") %>% 
        setView(lng=p$lng, lat=p$lat, input$Map_zoom) %>% 
        addCircleMarkers(p$lng, p$lat, 
                         radius=10, 
                         color="black", 
                         fillColor="orange", 
                         fillOpacity=1, 
                         opacity=1, 
                         stroke=TRUE, 
                         layerId="Selected")
    }
  })
  
  observeEvent(input$Map_marker_click, {
    p <- input$Map_marker_click
    if(!is.null(p$id)){
      if(is.null(input$location)) updateSelectInput(session, "location", selected=p$id)
      if(!is.null(input$location) && input$location!=p$id) updateSelectInput(session, "location", selected=p$id)
    }
  })
  
  # Tab 1: Graph ####################################################################################
  
  output$Chart1 <- renderPlotly({
    ## Note: the graph will be blank until a ID is selected
    if(!length(input$mw) || input$location=="") return(plotly())
    wselected() %>% 
      plot_ly(x = ~Date) %>%
      add_lines(y = DTW, name = input$mw, mode = 'line+markers') %>%
      layout(
        title = FALSE,
        # title = paste0("Monitoring Well ID: ", input$location),
        xaxis = list(
          title = "Date",
          rangeselector = list(
            buttons = list(
              list(
                count = 3,
                label = "3 Months",
                step = "month",
                stepmode = "backward"),
              list(
                count = 6,
                label = "6 Months",
                step = "month",
                stepmode = "backward"),
              list(
                count = 1,
                label = "1 Year",
                step = "year",
                stepmode = "backward"),
              list(step = "all", label = "All"))),
          rangeslider = list(type = "date")),
        yaxis = list(title = "Depth to Water (m)")) %>% 
      config(displayModeBar = FALSE) %>% 
      add_annotations(
        yref="paper", 
        xref="paper", 
        y=1.15, 
        x=1, 
        text = paste0(input$mw, " Hydrograph"), 
        showarrow=F, 
        font=list(size=15)
      )
  })
  
  
  # Tab 2 ####################################################################################
  
  # Reactive Objects
  # when the date changes inside date_range, the wells table will also change to dosplay something different inside the plot
  wselected <- reactive({
    if(input$district=="--"){
      wdata %>% left_join(wells, by="ID") %>%
        filter(Date %in% input$date_range)
    } else {
      wdata %>% left_join(wells, by="ID") %>% 
        filter(Date %in% input$date_range,
               District == input$district)
    }
  })
  
  # Graph for all wells
  output$network <- renderPlotly({
    # Color palette
    nw <- wells$ID %>% unique() %>% length()
    wells_pal <- colorRampPalette(brewer.pal(12,"Dark2"))(nw)
    # Plotting
    ggplot(wselected, mapping = aes(x = Date, y = DTW)) + 
      ggtitle("Niveles Piezométricos en Pozos de Observación") +
      geom_line(mapping = aes(color = ID)) +
      geom_point(mapping = aes(color = ID), size = 1.5) +
      geom_smooth(color = "grey45") + theme_light() +
      scale_colour_manual(values = wells_pal) +
      scale_x_date(name = "Fecha", date_breaks = "3 months", date_labels = "%b %Y") +
      labs(y = "Profundidad al Nivel Estático (m)", x = "Fecha") +
      theme(axis.text.x = element_text(angle = 45)) %>% 
      ggplotly()
  })
  


  # Download All Data
  output$download_all_data <- downloadHandler(
    # This function returns a string which tells the client browser what name to use when saving the file.
    filename = function() {
      paste('data-', Sys.Date(), '.csv', sep='')
    },
    
    # This function should write data to a file given to it by the argument 'file'.
    content = function(filename) {
      # Write to a file specified by the 'file' argument
      write.table(wells %>% left_join(wdata, by="ID"), filename, sep = ",", row.names = FALSE)
    }
  )
  
})