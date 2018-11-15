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
            width = 12,
            h4("")
          )
        ),
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
                          plotlyOutput("Chart1"))),
          bsTooltip(
            id = "location", 
            title = "Haz click en el mapa y luego seleccional de la lista", 
            placement = "top", 
            options = list(container="body")
          )
        )
      ),
      
      # Tab 2: Datos
      conditionalPanel(
        condition = "input.tsp=='network'",
        fluidRow(
          column(
            width = 12,
            h4("")
          )
        ),
        fluidRow(
          column(
            width = 8,
            fluidRow(
              column(
                width = 6,
                dateRangeInput("date_range", label = "Fechas",
                               start = min(np$Date), end = max(np$Date), 
                               width="100%")
              )
            )
          ),
          bsTooltip(
            id = "date_range", 
            title = "Selecciona rango de fechas", 
            placement = "top", 
            options = list(container="body")
          ),
          fluidRow(
            column(
              width = 12,
              plotlyOutput("network", width = "100%")
            )
          ),
          fluidRow(
            column(
              width = 6,
              offset = 1,
              downloadButton(
                outputId = "download_all_data", 
                label = "Descargar Datos", 
                width = "100%", top = 50)
            )
          )
        )
      ),

      # Tab 3: Más Información
      conditionalPanel("input.tsp=='about' ")
    )
  )
)