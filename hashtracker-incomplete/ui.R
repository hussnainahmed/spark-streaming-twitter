library(shiny)
library(ggplot2)
library(plyr)
library(RMySQL)
#library(googleCharts)
library(googleVis)


shinyUI(fluidPage(
  # progressInit(),
  #googleChartsInit(),
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
  tags$link(
    href=paste0("http://fonts.googleapis.com/css?",
                "family=Source+Sans+Pro:300,600,300italic"),
    rel="stylesheet", type="text/css"),
  tags$style(type="text/css",
             "body {font-family: 'Source Sans Pro'}"
  ),
  h3("Pakistan Tehreek -e- Insaf Twitter Hashtag Tracker"),
  fluidRow(
          
    sidebarPanel(
      #numericInput("n", "#", min = 0, max = 100, value = 50),
      textInput("hashtag_text", label = h4("Enter Hashtag Text"), value = "#KPKUpdates"),
      submitButton("Track!")
    ),
    mainPanel(
      verbatimTextOutput("hText"),
      htmlOutput('donut1')
    )

                   
                   
#              mainPanel(
#                wellPanel(plotOutput('plot1',height = 600, width = 1400))
#                
# #                tabsetPanel(
# #                  tabPanel("Median",h4("Rolling Median Speed"),plotOutput("plot1"))
# #                  )
#                )
             
             
             
  )
  
))
