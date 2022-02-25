library(shiny)
library(ggplot2)
library(plyr)
library(RMySQL)
library(zoo)



fluidPage(
  # progressInit(),
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
  navbarPage("Pakistan Tehreek -e- Insaf - Twitter Analysis  ",
             tabPanel("Live Sentiment",
                      #titlePanel("Rolling Medians of Vehicle Speed Per Lane"),
                       fluidRow(
#                         #column(3,numericInput('clusters','Number of Cluster', 4, min = 2, max = 10, step = 1)),
#                         column(2,selectInput("lane", "Select Lane", choices =c("All","4","5","6","7","8"))),
#                         column(2,selectInput("interval", "Rolling Mean Time Wndow (in minutes)", choices =c("1","5","10"))),
#                         
#                         
                        column(4,radioButtons('time_sel', 'Time Window Selection',
                                               c('Number of Previous Hours '='yes',
                                                 'Date range' = 'aday'),
                                               'yes')),
#                         # column(5,)
#                         
#                         
                         column(4,uiOutput("ui")),
                         column(2,uiOutput("ui_s_hr")),
                         column(2,uiOutput("ui_e_hr"))
#                         
#                         #column(3,uiOutput("ui_f"))
#                         
#                         
                      ),
                      #wellPanel(showOutput("chart_all","polycharts"))
                      #wellPanel(plotOutput('plot1'))
                      wellPanel(plotOutput('plot1',height = 500))
                      #plotOutput("plot1")
             )
#              mainPanel(
#                wellPanel(plotOutput('plot1',height = 600, width = 1400))
#                
# #                tabsetPanel(
# #                  tabPanel("Median",h4("Rolling Median Speed"),plotOutput("plot1"))
# #                  )
#                )
             
             
             
  )
  
)
