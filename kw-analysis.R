#start connection to TwitterApi


library(twitteR)
load("~/OAuth.RData")
registerTwitterOAuth(oauth)

#look for a specific keywords and retrieve n results
tweets = searchTwitter ("#cw13", n=1000)

#save results in a table
table.tweets  <- twListToDF(tweets)


# descriptive statistics for the created table

summary(table.tweets)
library(calibrate)
plot(x=table.authors$followers, y=table.authors$listed)
textxy(table.authors$followers,table.authors$listed, table.authors$RealName, cx= 0.9, dcol="red")
plot(x=table.authors$followers, y=table.authors$published)
#textmining



library(tm)
library(wordcloud)
# obtiene el texto de los tweets
txt = table.tweets$text

##### inicio limpieza de datos #####
# remueve retweets
txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
# remove @otragente
txtclean = gsub("@\\w+", "", txtclean)
# remueve simbolos de puntuación
txtclean = gsub("[[:punct:]]", "", txtclean)
# remove números
txtclean = gsub("[[:digit:]]", "", txtclean)
# remueve links
txtclean = gsub("http\\w+", "", txtclean)
##### fin limpieza de datos #####

# construye un corpus
corpus = Corpus(VectorSource(txtclean))

# convierte a minúsculas
corpus = tm_map(corpus, tolower)
# remueve palabras vacías (stopwords) en español
corpus = tm_map(corpus, removeWords, c(stopwords("spanish"), "camila_vallejo"))
# carga archivo de palabras vacías personalizada y lo convierte a ASCII
sw <- readLines("~/stopwords.es.txt",encoding="UTF-8")
sw = iconv(sw, to="ASCII//TRANSLIT")
# remueve palabras vacías personalizada
corpus = tm_map(corpus, removeWords, sw)
# remove espacios en blanco extras
corpus = tm_map(corpus, stripWhitespace)

# crea una matriz de términos
tdm <- TermDocumentMatrix(corpus)

# convierte a una matriz
m = as.matrix(tdm)

# conteo de palabras en orden decreciente
wf <- sort(rowSums(m),decreasing=TRUE)

# crea un data frame con las palabras y sus frecuencias
dm <- data.frame(word = names(wf), freq=wf)
# grafica la nube de palabras (wordcloud)
wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))



#crea un excel
library(xlsx) #load the package
write.xlsx(x = table.tweets, file = "mentions.twitter.xlsx",
           sheetName = "Tweets", row.names = FALSE)
write.xlsx(x = table.authors, file = "authors.twitter.xlsx",
           sheetName = "Authors", row.names = FALSE)
