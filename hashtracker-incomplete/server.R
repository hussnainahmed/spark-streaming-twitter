library(shiny)
library(ggplot2)
library(plyr)
library(RMySQL)
library(stringr)
library(googleCharts)
library(googleVis)

shinyServer(function(input, output, session) {
  
  get_data <- function (search_hashtag = "#KPKUpdates" ) {
    #metric="noptel-batch-rmedian"
    #metric_stream= "noptel-stream"
    drv <- dbDriver("MySQL")
    gcon = dbConnect(drv, user='root', password='ptifinf94', dbname='ptitweets', host='45.55.231.94')
    rec = dbSendQuery(gcon, 'SELECT * from tweet_text where text IS NOT NULL')
    data = fetch(rec, n = -1)
    dbDisconnect(gcon)
    data$created_at = as.POSIXct(data$created_at,"Asia/Karachi")
    hashtag.regex <- perl("(?<=^|\\s)#\\S+")
    data$hashtags <- str_extract_all(data$text, hashtag.regex)
    trim <- function (x) gsub("^\\s+|\\s+$", "", x)
    data$text <- trim(data$text)
    hash_df = data[grepl(search_hashtag, data$hashtags), ]
    #hash_df = data[which(data$hashtags == search_hashtag), ]
    hash_df$is_rt <- ifelse(grepl('RT', hash_df$text) == TRUE, 1, 0)
    hash_df$is_original <- ifelse(grepl('RT', hash_df$text) == TRUE, 0, 1)
    hash_df
    
  }
  
  
  output$hText <- renderPrint({
    
    tracker = get_data(input$hashtag_text)
    rt_count = sum(tracker$is_rt)
    original_count = sum(tracker$is_original)
   cat(paste0("Total Tweet Count : ",rt_count+original_count),paste0("Original Tweets Count : ",original_count),paste0("Re-tweets Count : ",rt_count),sep = "\n")
  })
  
  output$donut1 <- renderGvis({
    df = get_data(input$hashtag_text)
    df$Tweet_Type <- ifelse(df$is_rt == 1, "Re-tweets", "Original")
    df_agg = count(df,"Tweet_Type")
    doughnut <- gvisPieChart(df_agg, 
                             options=list(
                               width=400,
                               height=400,
                               slices="{0: {offset: 0},
                               1: {offset: 0},
                               2: {offset: 0}}",
                               title='',
                               legend='none',
                               colors="['red','green']",
                               pieSliceText='label',
                               pieSliceText='percentage',
                               pieHole=0.35),
                             chartid="doughnut")
    doughnut
#     df_agg$fraction = df_agg$freq / sum(df_agg$freq)
#     df_agg = df_agg[order(df_agg$fraction), ]
#     df_agg$ymax = cumsum(df_agg$fraction)
#     df_agg$ymin = c(0, head(df_agg$ymax, n=-1))
#     df_agg <- df_agg[ ,c(2,1,3:5)]
#     colnames(df_agg)[1] <- "count"
#     colnames(df_agg)[2] <- "category"
#     p2 <- ggplot(df_agg, aes(fill=category, ymax=ymax, ymin=ymin, xmax=4, xmin=3)) 
#     p2 + geom_rect(colour="white") + 
#        coord_polar(theta="y") +
#        xlim(c(0, 4)) +
#        scale_fill_manual(values = c("#CC0000", "#339900")) +
#        theme_bw() +
#        theme(panel.grid=element_blank()) +
#        theme(axis.text=element_blank()) +
#        theme(axis.ticks=element_blank()) +
#        theme(legend.position = "none") +
#        labs(title="Re-tweets vs Original Tweets")
  })
     
})
