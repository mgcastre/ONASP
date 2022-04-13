shinyUI(
  fluidPage(
    theme = shinytheme("cerulean"),
    titlePanel("ONASP"),
    tabsetPanel(
      id = "tsp",
      tabPanel("Interactive Map", value="map"),
      tabPanel("Data", value="network"),
      tabPanel("About", value="about"),
      
      # Tab1 : Interactive Map
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
                          h3("Monitoring Well"),
                          selectInput(inputId = "mw", label = "Select a monitoring well", 
                                      choices = c("", as.character(wells$ID)),
                                      selected = "", multiple = F, width = "100%"),
                          plotlyOutput("Chart1"))),
          bsTooltip(
            id = "mw", 
            title = "Click on the map and then select from the dropdown menu", 
            placement = "botom", 
            options = list(container="body")
          )
        )
      ),
      
      # Tab 2: Data
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
            width = 4,
            dateRangeInput("date_range", label = "Date Range",
                           start = min(wdata$Date), end = max(wdata$Date), 
                           width="100%"),
            bsTooltip(id = "date_range",
                      title = "Select a date range",
                      placement = "bottom",
                      options = list(container="body"))
          ),
          column(
            width = 4,
            selectInput("district", label = "District", 
                        choices = c("--", unique(wells$District)), 
                        selected = "--", width = "100%"),
            bsTooltip(id = "district",
                      title = "Filter data by district or select all",
                      placement = "bottom",
                      options = list(container="body"))
          ),
          column(
            width = 2,
            downloadButton(outputId = "download_all_data",
                           label = "Descargar Datos",
                           width = "100%", height = 50),
            bsTooltip(id = "download_all_data",
                      title = "Haz click para descagar todos los datos, o el grupo de datos seleccionados",
                      placement = "bottom",
                      options = list(container="body"))
          )
        ),
        fluidRow(
            column(
              width = 12,
              plotlyOutput("network", width = "100%", height = 450)
            )
        )
      ),

      # Tab 3: About
      conditionalPanel("input.tsp=='about' ")
    )
  )
)