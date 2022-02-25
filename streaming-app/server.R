library(shiny)
library(ggplot2)
library(plyr)
library(zoo)
library(RMySQL)


shinyServer(function(input, output, session) {
  autoInvalidate <- reactiveTimer(300000, session)
  get_data <- function (minutes = 240) {
    #metric="noptel-batch-rmedian"
    #metric_stream= "noptel-stream"
    drv <- dbDriver("MySQL")
    gcon = dbConnect(drv, user='root', password='ptifinf94', dbname='ptitweets', host='45.55.231.94')
    rec = dbSendQuery(gcon, 'SELECT * from pti_sent')
    data = fetch(rec, n = -1)
    dbDisconnect(gcon)
    data$dt = as.POSIXct(data$dt,"Asia/Karachi")
    #end_time =  as.POSIXct(as.character(data[nrow(data),1]),format="%Y-%m-%d %H:%M", "Asia/Karachi") 
    end_time = Sys.time()
   # attr(end_time, "tzone") <- "Asia/Karachi"
    start_time = end_time - (minutes * 60)
    sel = data[data$dt >= start_time & data$dt <= end_time ,]
    pos <- sel[ sel$sentiment=="positive", ]
    neg <- sel[ sel$sentiment=="negative", ]
    pos$smooth<-rollmean(pos$counter,10,fill="extend")
    neg$smooth<-rollmean(neg$counter,10,fill="extend")
    sel <- rbind(pos,neg)
    sel <- sel[order(sel$dt),]
    sel
  }
     
  output$ui <- renderUI({
    
    # Depending on input$month_sel, we'll generate a different
    # UI component and send it to the client.
    if(input$time_sel == "yes")
    {
      sliderInput("hours", "Prior hours to include:", 1, 168, 12, 1)
    } 
    else if (input$time_sel == "aday")
    {
      #dateInput("day_sel", "Select a day", value = format(Sys.time(), "%Y-%m-%d"), min = "2014-09-20", max = NULL, format = "yyyy-mm-dd", startview = "month", weekstart = 0, language = "en")
      dateRangeInput('dateRange',
                     label = 'Date range input: yy-mm-dd',
                     start = Sys.Date() - 1, end = Sys.Date(),
                     format = "yy-mm-dd"
      )
    }
    
  })
    output$ui_s_hr <- renderUI({
      if (input$time_sel == "aday")
        sliderInput("start_hr", "From start of hour:", 00, 23, 00, 01)  
      })
      output$ui_e_hr <- renderUI({
        if (input$time_sel == "aday")
        sliderInput("end_hr", "To end of hour:", 00, 23, 23, 01) 
      })

  time_sel_Input <- reactive(input$time_sel)
  hoursInput <- reactive(input$hours)
  start_hr_Input <- reactive(input$start_hr)
  end_hr_Input <- reactive(input$end_hr) 

  output$plot1 <- renderPlot({
    autoInvalidate()    
    #inter =  intervalInput()
      last_minutes = (hoursInput()+1) * 60
      if(time_sel_Input()=="yes"){
        
        df = get_data(last_minutes)
        g <- ggplot(df,aes(x=dt,y=smooth,color= sentiment))
        g + geom_line(size=0.7) + 
          ggtitle("PTI Twitter Sentiment Analysis") +  xlab("Date & Time") + 
          #coord_cartesian(ylim = c(30, 60)) +
          ylab("Per minute tweet count ") 
          #scale_colour_brewer(palette="Set3") 
    }
      
    else {
      start = input$dateRange[1]
      end = input$dateRange[2]
    
      last_days = as.numeric(Sys.Date() - start)
      if(last_days < 1) { 
        last_days = 1
      }
      else {
        last_days = last_days
      }
      s_hr = start_hr_Input()
      e_hr = end_hr_Input()
      mins = last_days*24*60 + s_hr*60 + (e_hr) *60
      df <- get_data(mins)
      s = as.POSIXct(strptime(paste0(start," ",s_hr), "%Y-%m-%d %H"))
      e = as.POSIXct(strptime(paste0(end," ",e_hr), "%Y-%m-%d %H"))
     #attr(s, "tzone") <- "Asia/Karachi"
     #attr(e, "tzone") <- "Asia/Karachi"
      df <- df[df$dt >= s & df$dt <= e ,]
      g <- ggplot(df,aes(x=dt,y=smooth,color= sentiment))
      g + geom_line(size=0.7) + 
        ggtitle("PTI Twitter Sentiment Analysis") +  xlab("Date & Time") + 
        #coord_cartesian(ylim = c(30, 60)) +
        ylab("Per minute tweet count ") 
      
    }
       
    
})
})
