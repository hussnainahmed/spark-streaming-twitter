library(plyr)
library(stringr)
library(ggplot2)

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
hu.liu.pos = scan('positive_words.txt', what='character', comment.char=';')
hu.liu.neg = scan('negative_words.txt', what='character', comment.char=';')

#Add words to list
pos.words = c(hu.liu.pos, 'upgrade', 'justice','dhandlileaguehayakaro','riging', 'wewantnstoresignnow','gonawazgo','azadisquare','Pakistan Khan')
neg.words = c(hu.liu.neg, 'saynotopaidsmts','ptikabsudhrogey','FarewellJusticeWajihUddin')

#Import 3 csv
raw = read.csv("/tmp/out_tweet/tweet_text",header=FALSE,sep=">")
colnames(raw) <- c("text","time")
tweets <- raw[!(is.na(raw$time) | raw$time==""), ]
#myCorpus <- Corpus(VectorSource(tweets$text))
#myCorpus <- tm_map(myCorpus, removePunctuation)
#myCorpus <- tm_map(myCorpus, removeNumbers)
#myStopwords <- c(stopwords('english'), "available", "via")
#idx <- which(myStopwords == "r")
#myCorpus <- tm_map(myCorpus, removeWords, myStopwords)
#tweets$text<-as.factor(tweets$text)
#DatasetAthletics <- read.csv("C:/temp/AthleticsTweets.csv")
#DatasetAthletics$text<-as.factor(DatasetAthletics$text)

#DatasetMLB <- read.csv("C:/temp/MLBTweets.csv")
#DatasetMLB$text<-as.factor(DatasetMLB$text)


#Score all tweets
tweets.scores = score.sentiment(tweets$text, pos.words,neg.words, .progress='text')
#Athletics.scores = score.sentiment(DatasetAthletics$text, pos.words,neg.words, .progress='text')
#MLB.scores = score.sentiment(DatasetMLB$text, pos.words,neg.words, .progress='text')
tweets.scores$time <- tweets$time
tweets.scores <- subset(tweets.scores, tweets.scores[ , 1] != 0)
tweets.scores$sentiment <- ifelse(tweets.scores$score<0,"negative","positive")
#tweets.scores$sentiment <- ifelse(tweets.scores$score>0,"positive",0)
#tweets.scores$score <- NULL
#tweets.scores$text <- NULL
tweets.scores$time<- as.POSIXct(tweets.scores$time, format="%a %b %d %H:%M:%S %z %Y")
attr(tweets.scores$time, "tzone") <- "Asia/Karachi"
tweets.scores$time <- format(tweets.scores$time, "%a %b %d %H:%M:%S %z %Y")
path<-"../data_preprocessed/"
write.csv(tweets.scores,file=paste(path,"TweetsScores.csv",sep=""),row.names=FALSE)
#write.csv(Athletics.scores,file=paste(path," AthleticsScores.csv",sep=""),row.names=TRUE)
#write.csv(MLB.scores,file=paste(path,"MLBScores.csv",sep=""),row.names=TRUE)
# sent <- tweets.scores
# g <- ggplot(sent, aes(time, fill=sentiment))
# g + geom_bar(binwidth = 1) + scale_fill_brewer()

#tweets.scores$Team = 'tweets'
#Athletics.scores$Team = 'Athletics'
#MLB.scores$Team = 'MLB'

#tweets.scores <- subset(tweets.scores, tweets.scores[ , 1] != 0)
#############################
#Chunk -5- Visualizing
#############################

#hist(tweets.scores$score)
#qplot(tweets.scores$score)

