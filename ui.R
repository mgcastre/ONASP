shinyUI(fluidPage(theme = shinytheme("cerulean"),
                  titlePanel("ONAS: Observatorio Nacional de Aguas Subterráneas"),
                  tabsetPanel(
                   tabPanel("Mapa Interactivo", value="map"),
                   tabPanel("Datos", value="network"),
                   tabPanel("Más Información", value="about"),
                   id="tsp",
                   
                   # chart panel
                   conditionalPanel(condition = "input.tsp=='map'",
                                    
                                    div(class="outer",
                                        
                                        tags$head(
                                          # Include our custom CSS
                                          includeCSS("styles.css"),
                                          includeScript("gomap.js")
                                        ),
                                        
                                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                                        leafletOutput("map"),
                                        
                                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                                      draggable = FALSE, top = 150, left = "auto", right = 20, bottom = "auto",
                                                      width = 500, height = "auto",
                                                      
                                                      h2("Pozos de Monitoreo"),
                                                      
                                                      selectInput(inputId = "location", label = "Seleccionar Pozo", 
                                                                  choices = c("", unique(np$ID)), 
                                                                  selected = "", multiple = F, width = "100%"),
                                                      
                                                      plotlyOutput("Chart1")
                                        )
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
                                    bsTooltip("location", "Seleccionar pozo de la lista o haz clic en el mapa.", "top", options = list(container="body")),
                                    
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
                  
)))
