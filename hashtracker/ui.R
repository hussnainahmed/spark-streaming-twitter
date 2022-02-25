library(shiny)
library(plyr)
library(RMySQL)
library(googleVis)
library(gdata)
#library(rCharts)
require(rCharts)
library(DT)

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
          
  sidebarLayout(  
    sidebarPanel(
      #numericInput("n", "#", min = 0, max = 100, value = 50),
      textInput("hashtag_text", label = h4("Enter Hashtag Text"), value = "#KPKUpdates"),
      p("Please use # with your inputs"),
      submitButton("Track!"),
      br(),
      h4("Twitter Top Trends (Pakistan) "),
      p("updates every 15 minutes"),
      dataTableOutput("top_trends")
      #textOutput("toptrends")
      #includeText("pak_twitter_trends.txt")
    ),
    mainPanel(
      verbatimTextOutput("hText"),
      htmlOutput('donut1'),
      #htmlOutput('bar1')
      showOutput("bar1", "nvd3")
      
    ),
    fluid = TRUE

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
