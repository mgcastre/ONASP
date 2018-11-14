shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("ONAS: Observatorio Nacional de Aguas Subterráneas"),
                  tabsetPanel(
                   tabPanel("Mapa Interactivo", value="map"),
                   tabPanel("Datos", value="network"),
                   tabPanel("Más Información", value="about"),
                   id="tsp",
                   
                   # chart panel
                   conditionalPanel(condition = "input.tsp=='map'",
                                    
                                    # row 1
                                    fluidRow(column(6, leafletOutput("Map")),
                                    column(6, offset = 6,
                                           fluidRow(column(12, 
                                                     selectInput("location", "Seleccionar Pozo", 
                                                                c("", unique(np$ID)), 
                                                                selected="", multiple=F, width="100%")),
                                                    column(12, plotlyOutput("Chart1"))
                                    )),
                                    
                                    # row 2
                                    fluidRow(
                                      column(2, actionButton("help_loc_btn", "Site Info", class="btn-block"), br()),
                                      column(2, actionButton("help_rcp_btn", "Recharge", class="btn-block")),
                                      column(7, h5(HTML(paste(caption, '<a href="http://ucwater.org/" target="_blank">ucwater.org</a>'))))
                                    )
                   ),
                   
                   
                   # network panel	
                   conditionalPanel("input.tsp=='network'", 
                                    fluidRow(
                                      column(8,
                                             fluidRow(
                                               column(6, 
                                                      dateRangeInput("date_range", "Date Range", 
                                                                     start = min(np$Date), 
                                                                     end = max(np$Date), width="100%"))
                                             )
                                      )
                                    ),
                                    bsTooltip("location", "Enter or select a monitoring well ID. You may also select a monitoring well using the map.", "top", options = list(container="body")),
                                    
                                    fluidRow(
                                      column(12, 
                                             plotlyOutput("network"))), br(),
                                    fluidRow(
                                      column(6, 
                                             downloadButton("download_all_data", "Download All Data", width = "100%")),
                                      column(8,
                                             h5("Data for download is available in CSV format and is updated daily as new data is received. This webapp displays daily averages of monitoring well data, whereas the raw data comes at hourly intervals."))
                                    )
                   ),
                   
                   
                   # about panel
                   conditionalPanel("input.tsp=='about' ")
))))
