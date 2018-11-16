shinyServer(function(input, output, session){
  
  # Tab 1: Map ####################################################################################
  
  # when the ID changes, so does the data for the plot
  ID <- reactive({
    np %>% filter(ID == input$location)
  })
  
  # when a ID is chosen in the drop down menu, change the map popup
  observeEvent(input$location, {
    p <- input$Map_marker_click
    p2 <- ll %>% filter(ID==input$location)
    if(nrow(p2)==0){
      leafletProxy("Map") %>% removeMarker(layerId="Selected")
    } else if(is.null(p$id) || input$location != p$id){
      leafletProxy("Map") %>% 
        setView(lng=p2$lng, lat=p2$lat, input$Map_zoom) %>% 
        addCircleMarkers(p2$lng, p2$lat, 
                         radius=10, color="black", fillColor="orange", 
                         fillOpacity=1, opacity=1, stroke=TRUE, 
                         layerId="Selected")
    }
  })
  
  # when a ID is selected, it is added to the location log
  # observeEvent(input$location, {
  #   x <- input$location
  #   if(!is.null(x) && x!=""){
  #     sink("locationLog.txt", append=TRUE, split=FALSE)
  #     cat(paste0(x, "\n"))
  #     sink()
  #   }
  # })
  
  # leaflet output of wells
  output$Map <- renderLeaflet({
    np_sp %>% 
      leaflet() %>% 
      addProviderTiles(providers$Esri.WorldImagery) %>% 
      #setView(lng=-121.378, lat=38.30139, zoom=13) %>%
      addCircleMarkers(label = ~ID,
                       stroke=FALSE, 
                       fillOpacity=.6, 
                       color= "dodgerblue",
                       radius = 3,
                       layerId = ~ID)
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
    if(!length(input$location) || input$location=="") return(plotly()) # blank until a ID is selected
    
    # plot
    ID() %>% 
      plot_ly(x = ~Date) %>%
      add_lines(y = ~(-1*Value), name = input$location, mode = 'line+markers') %>%
      layout(
        title = FALSE,
        # title = paste0("Monitoring Well ID: ", input$location),
        xaxis = list(
          title = "Fecha",
          rangeselector = list(
            buttons = list(
              list(
                count = 3,
                label = "3 Meses",
                step = "month",
                stepmode = "backward"),
              list(
                count = 6,
                label = "6 Meses",
                step = "month",
                stepmode = "backward"),
              list(
                count = 1,
                label = "1 Año",
                step = "year",
                stepmode = "backward"),
              list(
                count = 1,
                label = "Este Año",
                step = "year",
                stepmode = "todate"),
              list(step = "all", label = "Todo"))),
          
          rangeslider = list(type = "date")),
        
        yaxis = list(title = "Profundidad al Nivel Estático (m)")) %>% 
      config(displayModeBar = FALSE) %>% 
      add_annotations(
        yref="paper", 
        xref="paper", 
        y=1.15, 
        x=1, 
        text = paste0(input$location, " Hidrograma"), 
        showarrow=F, 
        font=list(size=15)
      )
  })
  
  
  # Tab 2 ####################################################################################
  
  # Graph for all wells
  output$network <- renderPlotly({
    # Color palette
    n_pozos <- np$ID %>% unique() %>% length()
    pozos_pal <- colorRampPalette(brewer.pal(12,"Set3"))(n_pozos)
    # Plotting
    figure <- left_join(np, ll, by = "ID") %>% 
      mutate(NE = -1*Value, ID = as.factor(ID)) %>% 
      ggplot(mapping = aes(x = Date, y = NE)) + 
      geom_line(mapping = aes(color = ID)) + 
      geom_smooth(color = "black") + theme_dark() + 
      scale_colour_manual(values = pozos_pal) +
      labs(y = "Profundidad al Nivel Estático (m)", x = "Fecha")
    ggplotly(figure)
  })

  # Download All Data
  output$download_all_data <- downloadHandler(
    # This function returns a string which tells the client browser what name to use when saving the file.
    filename = function() {
      paste0("datos", ".csv")
    },
    
    # This function should write data to a file given to it by the argument 'file'.
    content = function(file) {
      # Write to a file specified by the 'file' argument
      write.table(np %>% spread(ID, Value), file, sep = ",", row.names = FALSE)
    }
  )
  
})