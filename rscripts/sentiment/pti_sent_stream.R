#!/usr/bin/R

library(plyr)
library(stringr)
library(ggplot2)
library(RMySQL)

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)

  # we got a vector of sentences. plyr will handle a list
  # or a vector as an "l" for us
  # we want a simple array ("a") of scores back, so we use
  # "l" + "a" + "ply" = "laply":

  scores = laply(sentences, function(sentence, pos.words, neg.words) {

    # clean up sentences with R's regex-driven global substitute, gsub():

    sentence = gsub('[[:punct:]]', '', sentence)

    sentence = gsub('[[:cntrl:]]', '', sentence)

    sentence = gsub('\\d+', '', sentence)

    # and convert to lower case:

    sentence = tolower(sentence)

    # split into words. str_split is in the stringr package

    word.list = str_split(sentence, '\\s+')

    # sometimes a list() is one level of hierarchy too much

    words = unlist(word.list)

    # compare our words to the dictionaries of positive & negative terms

    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)

    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:

    pos.matches = !is.na(pos.matches)

    neg.matches = !is.na(neg.matches)

    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():

    score = sum(pos.matches) - sum(neg.matches)

    return(score)

  }, pos.words, neg.words, .progress=.progress )
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}


############################################
#Chunk - 4 - Scoring Tweets & Adding a column
############################################

#Load sentiment word lists
hu.liu.pos = scan('/root/rscripts/sentiment/positive_words.txt', what='character', comment.char=';')
hu.liu.neg = scan('/root/rscripts/sentiment/negative_words.txt', what='character', comment.char=';')

#Add words to list
pos.words = c(hu.liu.pos, 'upgrade', 'justice','dhandlileaguehayakaro','riging', 'wewantnstoresignnow','gonawazgo','azadisquare','Pakistan Khan')
neg.words = c(hu.liu.neg, 'saynotopaidsmts','ptikabsudhrogey','FarewellJusticeWajihUddin')

#Import 3 csv
#raw = read.csv("../data_preprocessed/tweet_pti_20150429_30.txt",header=FALSE,sep=">")
mydb = dbConnect(MySQL(), user='root', password='ptifinf94', dbname='ptitweets', host='45.55.231.94')
raw = fetch(dbSendQuery(mydb, 'SELECT text,STR_TO_DATE(created_at,\'%Y-%m-%d %T\') as dt from tweet_text where STR_TO_DATE(created_at,\'%Y-%m-%d %T\') > (NOW() - INTERVAL 5 MINUTE)'))
dbDisconnect(mydb)
colnames(raw) <- c("text","time")
tweets <- raw[!(is.na(raw$time) | raw$time==""), ]

tweets.scores = score.sentiment(tweets$text, pos.words,neg.words, .progress='text')

tweets.scores$time <- tweets$time
tweets.scores <- subset(tweets.scores, tweets.scores[ , 1] != 0)
tweets.scores$sentiment <- ifelse(tweets.scores$score<0,"negative","positive")

tweets.scores$score <- NULL
tweets.scores$text <- NULL
tweets.scores$time<- as.POSIXct(tweets.scores$time, format="%Y-%m-%d %H:%M:%S")
#attr(tweets.scores$time, "tzone") <- "Asia/Karachi"
tweets.scores$count <- 1
tweets.scores$time  <- as.character(strptime(tweets.scores$time, "%Y-%m-%d %H:%M"))
tweets.scores <- aggregate(count ~ time+sentiment, data=tweets.scores, FUN=sum)
colnames(tweets.scores) <- c("dt","sentiment","counter")
#tweets.scores$dt<- as.POSIXct(tweets.scores$dt, format="%Y-%m-%d %H:%M") + 1*60*60
#attr(tweets.scores$dt, "tzone") <- "Asia/Karachi"
rcon = dbConnect(MySQL(), user='root', password='ptifinf94', dbname='ptitweets', host='45.55.231.94')
dbWriteTable(rcon, name='pti_sent', value=tweets.scores, overwrite=FALSE, append=TRUE, row.names=F)
dbDisconnect(rcon)
