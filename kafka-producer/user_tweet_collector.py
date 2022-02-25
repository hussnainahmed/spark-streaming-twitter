from tweepy import StreamListener
from tweepy import Stream
import tweepy

from kafka import KafkaClient, SimpleProducer

ckey='n9a3UxaAzJQo2hrJBG34TmrtB'
csecret='QqkbhqTb9CdpRVzWqyedQdn0FTKXtVCnBQNBG3Y44y63rOgZUx'
atoken='3241667152-joOJtJje5FSPvDvKyPbAs73Mw8H0hLA6Ui8M2JG'
asecret='N4Cp9ZXNUCrjDfX5kf2Fnu47jMRVNJcCjIoJtAANb75vX'



auth = tweepy.OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)
api = tweepy.API(auth)

class StdOutListener(StreamListener):

    def on_data(self, data):
        # process stream data here
        sendKafka(str(data))
	#print(data)


    def on_error(self, status):
        print(status)


def sendKafka(msg):
    host = "pti-node-2.insafanalytics.com:9092";
    topic = "user-tweets"

    kafka = KafkaClient(host)
    producer = SimpleProducer(kafka)

    producer.send_messages(topic, msg)

    kafka.close()


if __name__ == '__main__':
    listener = StdOutListener()
    twitterStream = Stream(auth, listener)
    tweet_data = twitterStream.filter(follow=['64622053','127483019','65635927','122453931','735314581','213539531'])
