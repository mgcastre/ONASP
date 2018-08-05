library(shiny)
library(googlesheets)
library(leaflet)

url <- gs_url("https://docs.google.com/spreadsheets/d/1YyoLssme-PZBF_C2Ko30E0GgLE3x92Z31iz04a0ZR9M/edit#gid=1936918230")
gs_key(x = "https://docs.google.com/spreadsheets/d/1YyoLssme-PZBF_C2Ko30E0GgLE3x92Z31iz04a0ZR9M/edit#gid=1936918230")



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
})
