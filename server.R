shinyServer(function(input, output, session){
  
  observeEvent(input$location, {
    x <- input$location
    if(!is.null(x) && x!=""){
      sink("locationLog.txt", append=TRUE, split=FALSE)
      cat(paste0(x, "\n"))
      sink()
    }
  })
  
  # leaflet output of wells
  output$Map <- renderLeaflet({
    np_sp %>% 
    leaflet() %>% 
      addProviderTiles(providers$Esri.WorldImagery) %>% 
      #setView(lng=-121.378, lat=38.30139, zoom=13) %>%
      addCircleMarkers(label = ~ID,
                       stroke=FALSE, 
                       fillOpacity=.6, 
                       color= "blue",
                       radius = 5,
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
  
  
  
  # when the ID changes, so does the data for the plot
  ID <- reactive({ 
    np %>% filter(ID == input$location)
  })
  

  
  
  # individual well plot
  output$Chart1 <- renderPlotly({
    if(!length(input$location) || input$location=="") return(plotly()) # blank until a ID is selected
    
    # plot
    ID() %>% 
      plot_ly(x = ~Date) %>%
      add_lines(y = ~value, name = input$location) %>% 
      layout(
        title = FALSE,
        # title = paste0("Monitoring Well ID: ", input$location),
        xaxis = list(
          rangeselector = list(
            buttons = list(
              list(
                count = 3,
                label = "3 mo",
                step = "month",
                stepmode = "backward"),
              list(
                count = 6,
                label = "6 mo",
                step = "month",
                stepmode = "backward"),
              list(
                count = 1,
                label = "1 yr",
                step = "year",
                stepmode = "backward"),
              list(
                count = 1,
                label = "YTD",
                step = "year",
                stepmode = "todate"),
              list(step = "all"))),
          
          rangeslider = list(type = "date")),
        
        yaxis = list(title = "Nivel (m)")) %>% 
      config(displayModeBar = FALSE) %>% 
      add_annotations(
        yref="paper", 
        xref="paper", 
        y=1.15, 
        x=1, 
        text = paste0(input$location, " Hydrograph"), 
        showarrow=F, 
        font=list(size=17)
      )
  })
  
  
  # map for all wells
  output$network <- renderPlotly({
    temp <- np %>% spread(ID, value)
    temp <- cbind.data.frame(temp[, -2], temp[, 2]) # re-arrange comentario column to end
    
    p <- qplot(Date, value, data = nr[,-4]) + # remove comentario from plot
      stat_smooth() 
    
    # get geom_smooth coords 
    ggplot_build(p)$data[[2]] %>% select(x,y,ymin,ymax) -> smooth
    
    #smooth$x <- as.Date(as.POSIXct(smooth$x, origin="1970-01-01"))
    smooth$x <- anytime(smooth$x)
    
    # plot 
    plot_ly(temp, x = ~Date) %>%
      add_lines(y = ~`PM-01`, name = "PM-01", color= I(pozos_pal[1])) %>%
      add_lines(y = ~`PM-02`, name = "PM-02", color= I(pozos_pal[2])) %>%
      add_lines(y = ~`PM-03`, name = "PM-03", color= I(pozos_pal[3])) %>%
      add_lines(y = ~`PM-04`, name = "PM-04", color= I(pozos_pal[4])) %>%
      add_lines(y = ~`PM-06`, name = "PM-06", color= I(pozos_pal[5])) %>%
      add_lines(y = ~`PM-07`, name = "PM-07", color= I(pozos_pal[6])) %>%
      add_lines(y = ~`PM-08`, name = "PM-08", color= I(pozos_pal[7])) %>%
      add_lines(y = ~`PM-09`, name = "PM-09", color= I(pozos_pal[8])) %>%
      add_lines(y = ~`PM-10`, name = "PM-10", color= I(pozos_pal[9])) %>%
      add_lines(y = ~`PM-12`, name = "PM-12", color= I(pozos_pal[10])) %>%
      add_lines(y = ~`PM-13`, name = "PM-13", color= I(pozos_pal[11])) %>%
      add_lines(y = ~`PM-14`, name = "PM-14", color= I(pozos_pal[12])) %>%
      add_lines(y = ~`PM-18`, name = "PM-18", color= I(pozos_pal[13])) %>%
      add_lines(y = ~`PM-19`, name = "PM-19", color= I(pozos_pal[14])) %>%
      add_lines(y = ~`PM-20`, name = "PM-20", color= I(pozos_pal[15])) %>%
      add_lines(y = ~`PM-21`, name = "PM-21", color= I(pozos_pal[16])) %>%
      add_lines(y = ~`PM-22`, name = "PM-22", color= I(pozos_pal[17])) %>%
      add_lines(y = ~`PM-24`, name = "PM-24", color= I(pozos_pal[18])) %>%
      add_lines(y = ~`PM-25`, name = "PM-25", color= I(pozos_pal[19])) %>%
      add_lines(y = ~`PM-26`, name = "PM-26", color= I(pozos_pal[20])) %>%
      add_lines(y = ~`PM-29`, name = "PM-29", color= I(pozos_pal[21])) %>%
      add_lines(y = ~`PM-31`, name = "PM-31", color= I(pozos_pal[22])) %>%
      add_lines(y = ~`PM-32`, name = "PM-32", color= I(pozos_pal[23])) %>%
      add_lines(y = ~`PM-33`, name = "PM-33", color= I(pozos_pal[24])) %>%
      add_lines(y = ~`PM-36`, name = "PM-36", color= I(pozos_pal[25])) %>%
      add_lines(y = ~`PM-37`, name = "PM-37", color= I(pozos_pal[26])) %>%
      add_lines(y = ~`PM-44`, name = "PM-44", color= I(pozos_pal[27])) %>%
      add_lines(y = ~`PM-60`, name = "PM-60", color= I(pozos_pal[28])) %>%
      add_lines(y = ~`PM-65`, name = "PM-65", color= I(pozos_pal[29])) %>%
      add_lines(y = ~`PM-71`, name = "PM-71", color= I(pozos_pal[30])) %>%
      add_lines(y = ~`PM-73`, name = "PM-73", color= I(pozos_pal[31])) %>%
      add_lines(y = ~`PM-74`, name = "PM-74", color= I(pozos_pal[32])) %>%
      add_lines(y = ~`PM-78`, name = "PM-78", color= I(pozos_pal[33])) %>%
      add_ribbons(data = smooth, x=~x, ymin=~ymin, ymax=~ymax, color = I("darksalmon"), name = "Confidence Interval") %>% 
      add_lines(data = smooth, x=~x, y=~y, color = I("red"), name = "AVERAGE") %>% 
      layout(
        showlegend = FALSE,
        title = FALSE, #"Entire Monitoring Well Network",
        xaxis = list(
          rangeselector = list(
            buttons = list(
              list(
                count = 3,
                label = "3 mo",
                step = "month",
                stepmode = "backward"),
              list(
                count = 6,
                label = "6 mo",
                step = "month",
                stepmode = "backward"),
              list(
                count = 1,
                label = "1 yr",
                step = "year",
                stepmode = "backward"),
              list(
                count = 1,
                label = "YTD",
                step = "year",
                stepmode = "todate"),
              list(step = "all"))),
          
          rangeslider = list(type = "date"),
          range = c( input$date_range[1], input$date_range[2]) 
        ),
        
        yaxis = list(title = "Nivel (m)")
        
      ) %>% 
      
      config(displayModeBar = FALSE)
    
  })
  
  # Download All Data
  output$download_all_data <- downloadHandler(
    # This function returns a string which tells the client browser what name to use when saving the file.
    filename = function() {
      paste0("panama_pozos_rios", ".csv")
    },
    
    # This function should write data to a file given to it by the argument 'file'.
    content = function(file) {
      # Write to a file specified by the 'file' argument
      write.table(np %>% spread(ID, value), file, sep = ",", row.names = FALSE)
    }
  )
  
})