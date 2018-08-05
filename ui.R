shinyUI(navbarPage(theme=shinytheme("spacelab"), 
                   title=HTML('<div><a href="http://ucwater.org/" target="_blank"><img src="./img/small_logo.png" width="80%"></a></div>'),
                   tabPanel("Pozos", value="commChart"),
                   tabPanel("Network", value="network"),
                   tabPanel("About", value="about"),
                   windowTitle="UC Water | Groundwater Observatory",
                   collapsible=TRUE,
                   id="tsp",
                   tags$head(includeScript("www/ga-cc4liteFinal.js"), includeScript("www/ga-allapps.js")),
                   tags$head(tags$link(rel="stylesheet", type="text/css", href="styles.css")),
                   
                   # chart panel
                   conditionalPanel("input.tsp=='commChart'",
                                    
                                    # row 1
                                    fluidRow(
                                      column(4, 
                                             h4("California Groundwater Observatory"), 
                                             h6("Real-time aquifer monitoring in the South American Subbasin")),
                                      column(8,
                                             fluidRow(
                                               column(6, 
                                                      selectInput("location", "Monitoring Well ID", 
                                                                  c("", unique(np$ID)), 
                                                                  selected="", multiple=F, width="100%"))
                                             )
                                      )
                                    ),
                                    bsTooltip("location", "Enter a monitoring well ID. The menu will filter as you type. You may also select a monitoring well using the map.", "top", options = list(container="body")),
                                    
                                    # row 2
                                    fluidRow(
                                      column(4, 
                                             leafletOutput("Map")),
                                      column(8,
                                             plotlyOutput("Chart1"),
                                             HTML('<style>.rChart {width: 100%; height: "auto"}</style>'))
                                    ),
                                    br(),
                                    
                                    # row 3
                                    fluidRow(
                                      column(2, actionButton("help_loc_btn", "Site Info", class="btn-block"), br()),
                                      column(2, actionButton("help_rcp_btn", "Recharge", class="btn-block")),
                                      column(7, h5(HTML(paste(caption, '<a href="http://ucwater.org/" target="_blank">ucwater.org</a>'))))
                                    ),
                                    bsModal("modal_loc", "Site Information", "help_loc_btn", size="large",
                                            includeMarkdown("data/site_info.md")),
                                    
                                    bsModal("modal_rcp", "Floodplain Recharge", "help_rcp_btn", size="large",
                                            includeMarkdown("data/recharge_info.md"))
                   ),
                   
                   
                   # network panel	
                   conditionalPanel("input.tsp=='network'", 
                                    fluidRow(
                                      column(4, 
                                             h4("California Groundwater Observatory"), 
                                             h6("Real-time aquifer monitoring in the South American Subbasin")),
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
                   conditionalPanel("input.tsp=='about'", includeMarkdown("data/about.md")) #source("about.R",local=T)$value)
                   
))
