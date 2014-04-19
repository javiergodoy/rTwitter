#start connection to TwitterApi


library(twitteR)
load("~/OAuth.RData")
registerTwitterOAuth(oauth)

#look for a specific keywords and retrieve n results
tweets = searchTwitter ("#keyword", n=1000)

#save results in a table
table.tweets  <- twListToDF(tweets)


# descriptive statistics for the created table

summary(table.tweets)
library(calibrate)
plot(x=table.authors$followers, y=table.authors$listed)
textxy(table.authors$followers,table.authors$listed, table.authors$RealName, cx= 0.9, dcol="red")
plot(x=table.authors$followers, y=table.authors$published)





####textmining#####


# import libraries
library(tm)
library(wordcloud)

# fetch the text of the tweets
txt = table.tweets$text

##### data cleaning #####
# remove retweets
txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
# remove @username
txtclean = gsub("@\\w+", "", txtclean)
# remove punctuation
txtclean = gsub("[[:punct:]]", "", txtclean)
# remove numbers
txtclean = gsub("[[:digit:]]", "", txtclean)
# remove links
txtclean = gsub("http\\w+", "", txtclean)
##### data cleaning #####

#corpus
corpus = Corpus(VectorSource(txtclean))

# convert to lower
corpus = tm_map(corpus, tolower)
# remove stopwords (en español)
corpus = tm_map(corpus, removeWords, c(stopwords("spanish"), "camila_vallejo"))
# upload personalized stopwords list and convert it to ASCII
sw <- readLines("~/stopwords.es.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
# remove personalized stopwords list
corpus = tm_map(corpus, removeWords, sw)
# remove extra white spaces
corpus = tm_map(corpus, stripWhitespace)

# create a corpus
tdm <- TermDocumentMatrix(corpus)

# convert to matrix
m = as.matrix(tdm)

# count words in decreasing order
wf <- sort(rowSums(m),decreasing=TRUE)

# create a dataframe with words and frecuencies
dm <- data.frame(word = names(wf), freq=wf)

# create a wordcloud
wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))



#create an excel file
library(xlsx) #load the package
write.xlsx(x = table.tweets, file = "mentions.twitter.xlsx",
           sheetName = "Tweets", row.names = FALSE)
