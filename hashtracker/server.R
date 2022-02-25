library(shiny)
library(plyr)
library(RMySQL)
library(stringr)
library(googleVis)
library(gdata)
library(reshape2)
#library(rCharts)
require(rCharts)
library(DT)

options(RCHART_WIDTH = 700)
options(RCHART_HEIGHT = 300)

killDbConnections <- function () {
  
  all_cons <- dbListConnections(MySQL())
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}

drv <- dbDriver("MySQL")
gcon = dbConnect(drv, user='root', password='ptifinf94', dbname='ptitweets', host='45.55.231.94')
rec = dbSendQuery(gcon, 'SELECT * from tweet_text where text IS NOT NULL')
data = fetch(rec, n = -1)
dbDisconnect(gcon)

trends = read.csv("pak_twitter_trends.txt",header = F)
trends$V2 <- NULL
colnames(trends) <- "Trending Hashtags & Keywords"

shinyServer(function(input, output, session) {
  
  get_data <- function (search_hashtag = "#KPKUpdates" ) {
    #metric="noptel-batch-rmedian"
    #metric_stream= "noptel-stream"
    data$created_at = as.POSIXct(data$created_at,"Asia/Karachi")
    hashtag.regex <- perl("(?<=^|\\s)#\\S+")
    data$hashtags <- str_extract_all(data$text, hashtag.regex)
    trim <- function (x) gsub("^\\s+|\\s+$", "", x)
    data$text <- trim(data$text)
    hash_df = data[grepl(paste0(search_hashtag,"\\b"), data$hashtags), ]
    #hash_df = data[which(data$hashtags == search_hashtag), ]
    hash_df$is_rt <- ifelse(grepl('RT', hash_df$text) == TRUE, 1, 0)
    hash_df$is_original <- ifelse(grepl('RT', hash_df$text) == TRUE, 0, 1)
    hash_df
    
  }
  
  
  output$hText <- renderPrint({
    
    track_df = get_data(input$hashtag_text)
    track_df$created_at = format(as.POSIXct(track_df$created_at), format = "%a %b-%d, %Y  %H:%M:%S", tz = "Asia/Karachi", usetz = TRUE)
    #track_df$created_at = strptime(track_df$created_at, "%a %b %e, %Y - %H:%M:%S %Z"),"Asia/Karachi")
    #text_sel <- track_df[startsWith( track_df$text, '@') | startsWith( track_df$text, 'RT @') ,1:2]
    text_sel <- track_df[startsWith( track_df$text, '@'),1:2]
    rt_count = sum(track_df$is_rt)
    original_count = sum(track_df$is_original)
    time_since = head(track_df[order(track_df$created_at),2],1) 
    cat(
      paste0("Total Tweet Count     : ",rt_count+original_count),
      paste0("Original Tweets Count : ",original_count,"     ",round(original_count*100/(original_count+rt_count),2),"%"),
      paste0("Re-tweets Count       : ",rt_count,"     ",round(rt_count*100/(original_count+rt_count),2),"%"), 
      paste0("@ Tweets              : ", nrow(text_sel)), 
      paste0(""),
      paste0("Tweet Collection Started Since :  ",time_since),
      sep = "\n")
   })
  
#    output$toptrends <- renderText({
#      print(trends,right=F)
#    })
  output$top_trends = renderDataTable({
    #trends,
    datatable(trends) %>% formatStyle(
      'Trending Hashtags & Keywords'
    )
  }
  )
  
  #output$donut1 <- renderGvis({
  output$donut1 <- renderGvis({
    df = get_data(input$hashtag_text)
    df$Tweet_Type <- ifelse(df$is_rt == 1, "Re-tweets", "Original")
    df_agg = count(df,"Tweet_Type")
    doughnut <- gvisPieChart(df_agg, 
                             options=list(
                               width=350,
                               height=350,
                               slices="{0: {offset: 0.1},
                               1: {offset: 0.1},
                               2: {offset: 0.1}}",
                               title='',
                               legend='none',
                               colors="['red','green']",
                               pieSliceText='label',
                               pieSliceText='percentage',
                               pieHole=0.3),
                             chartid="doughnut")
    
    
    doughnut
    
  })
  #output$bar1 <- renderGvis({
  output$bar1 <- renderChart2({
    df = get_data(input$hashtag_text)
    df$created_at = format(as.POSIXct(df$created_at), format = "%b-%d, %I%p", tz = "Asia/Karachi", usetz = F)
    df_hour <- aggregate(cbind(is_rt,is_original) ~ created_at, data=df , FUN=sum)
    colnames(df_hour) <- c("created_at","Re-tweets","Original")
    dfm = melt(df_hour, id.vars='created_at')
    n1 <- nPlot(value ~ created_at, group = "variable", data = dfm , type = "multiBarChart")
    n1$set(dom = "plot")
    n1$chart(color = c('green', 'red'))
    n1$yAxis( axisLabel = "Total Hourly Tweets" )
    n1$chart(margin = list(left = 100))
    #n1$setTemplate(
    #  afterScript = "<style>
    #  .tick line {
    #  stroke: none; fill: none;
     # }
      #</style>")
    #p1$guides(x = list(title = "Day & Hour"))
    #p1$guides(y = list(title = "Total Hourly Tweets"))
    return(n1)
#     Column <- gvisColumnChart(df_hour, 
#                               options=list(isStacked=TRUE, 
#                                            series="[
#                                            {color:'green',visibleInLegend: false},
#                                            {color:'red',visibleInLegend: false}]",
#                                            hAxes="[{
#                                            title:'Hours', 
#                                            gridlines: {
#                                            count: 6, 
#                                            units: {
#                                            days: {
#                                            format: ['dd']
#                                            },
#                                            hours: {
#                                            format: ['HH', 'ha']
#                                            }}}}]"))
#    Column
    
    
  })
     
})
