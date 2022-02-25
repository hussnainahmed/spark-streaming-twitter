from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import MySQLdb
import time
import json



#        replace mysql.server with "localhost" if you are running via your own server!
#                        server       MySQL username	MySQL pass  Database name.
conn = MySQLdb.connect("localhost","root","ptifinf94","ptitweets")

c = conn.cursor()


#consumer key, consumer secret, access token, access secret.
ckey="n9a3UxaAzJQo2hrJBG34TmrtB"
csecret="QqkbhqTb9CdpRVzWqyedQdn0FTKXtVCnBQNBG3Y44y63rOgZUx"
atoken="3241667152-joOJtJje5FSPvDvKyPbAs73Mw8H0hLA6Ui8M2JG"
asecret="N4Cp9ZXNUCrjDfX5kf2Fnu47jMRVNJcCjIoJtAANb75vX"

class listener(StreamListener):

    def on_data(self, data):
        all_data = json.loads(data)
        
        tweet = all_data["text"]
        
        username = all_data["user"]["screen_name"]
        
        c.execute("INSERT INTO taula (time, username, tweet) VALUES (%s,%s,%s)",
            (time.time(), username, tweet))

        conn.commit()

        print((username,tweet))
        
        return True

#    def on_error(self, status):
#        print status

auth = OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)

twitterStream = Stream(auth, listener())
twitterStream.filter(follow=["64622053","127483019","65635927","122453931","735314581","213539531"])
