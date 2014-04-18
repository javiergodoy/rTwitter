#connect to Twitter app created previously (see/create connection file)
library(twitteR)
load("~/OAuth.RData")
registerTwitterOAuth(oauth)