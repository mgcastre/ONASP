shinyUI(
  fluidPage(
    theme = shinytheme("cerulean"),
    titlePanel("ONAS: Observatorio Nacional de Aguas Subterráneas"),
    tabsetPanel(
      id = "tsp",
      tabPanel("Mapa Interactivo", value="map"),
      tabPanel("Datos", value="network"),
      tabPanel("Más Información", value="about"),
      
      # Tab1 : Mapa Interactivo
      conditionalPanel(
        condition = "input.tsp=='map'",
        fluidRow(
          column(
            width = 6,
            leafletOutput("Map", width = "100%", height = 530)),
          column(
            width = 6,
            absolutePanel(id = "controls", fixed = FALSE, width = "90%",
                          h3("Pozos de Monitoreo"),
                          selectInput(inputId = "location", label = "Seleccionar Pozo", 
                                      choices = c("", unique(np$ID)),
                                      selected = "", multiple = F, width = "100%"),
                          plotlyOutput("Chart1"))
          )
        )
      ),
      
      # Tab 2: Datos
      
      # Data and Graph Panel	
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
    )
  )
)