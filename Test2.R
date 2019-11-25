library(rjson)
library(dplyr)
library(googledrive)
library(htmltools)
library(plotly)


#drive_download("TestData.csv", type = "csv", overwrite = TRUE)
#expDF1 <- data.frame()
#expDF1 <- read.csv("TestData.csv")


#url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Knight.json"
#expDF <- jsonlite::fromJSON(url)
#expDF <- data.frame(expDF$highscores$data)
#expDF["time"] <- Sys.time()
#expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Wats Ke Burd"))

#url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Druid.json"
#expDF <- jsonlite::fromJSON(url)
#expDF <- data.frame(expDF$highscores$data)
#expDF["time"] <- Sys.time()
#expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Po Ni Teel"))

#url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Sorcerer.json"
#expDF <- jsonlite::fromJSON(url)
#expDF <- data.frame(expDF$highscores$data)
#expDF["time"] <- Sys.time()
#expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Don Teeltje"))

#url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Paladin.json"
#expDF <- jsonlite::fromJSON(url)
#expDF <- data.frame(expDF$highscores$data)
#expDF["time"] <- Sys.time()
#expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Ari Bombari"))

#write.csv(expDF1, file = "TestData.csv")

#drive_upload("TestData.csv")

#test

drive_auth(email = TRUE)

drive_download("TestData.csv", type = "csv", overwrite = TRUE)
#expDF1 <- data.frame()
expDF1 <- read.csv("TestData.csv")
expDF1$X <- NULL
expDF1$time <- as.Date(expDF1$time)
vocation <- c("Knight","Sorcerer","Druid","Paladin")
names <- c("Wats Ke Burd","Don Teeltje","Po Ni Teel","Ari Bombari")

options(timeout= 4000000)

for (i in 1:4) {
  url = paste("https://api.tibiadata.com/v2/highscores/Faluna/Experience/",vocation[i],".json", sep = "")
  expDF <- jsonlite::fromJSON(url)
  expDF <- data.frame(expDF$highscores$data)
  expDF["time"] <- as.Date(Sys.time())
  expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == names[i]))
}

write.csv(expDF1, file = "TestData.csv")

drive_rename("TestData.csv", name = "TestData2.csv")
drive_upload("TestData.csv")

# graph
maxExpDf <- aggregate(expDF1$points, by = list(expDF1$name), max)
y_min <- min(maxExpDf[,2])
#maxExpDf[maxExpDf$x == y_min, maxExpDf[,2]]
maxExpDf <- maxExpDf[which.min(maxExpDf$x), ]

expDF3 <- expDF1 %>% filter(expDF1$name == "Ari Bombari")
expDF3$level <- floor(expDF3$level/3*2)
expDF3$points <- 50/3 * (expDF3$level ** 3 - 6 * expDF3$level ** 2 + 17 * expDF3$level - 12)
expDF3$name <- "Minimum Exp Share Range"
expDF3$voc <- "na"
expDF3$rank <- 1
expDF1 <- rbind(expDF1, expDF3)

expDF3 <- expDF1 %>% filter(expDF1$name == as.character(maxExpDf$Group.1[[1]]))
expDF3$level <- floor(expDF3$level/2*3)
expDF3$points <- 50/3 * (expDF3$level ** 3 - 6 * expDF3$level ** 2 + 17 * expDF3$level - 12)
expDF3$name <- "Maximum Exp Share Range"
expDF3$voc <- "na"
expDF3$rank <- 1
expDF1 <- rbind(expDF1, expDF3)

p <- plot_ly(expDF1, 
             x = as.Date(expDF1$time), 
             y = expDF1$points, 
             text = paste("Level", expDF1$level), 
             color = expDF1$name, 
             type = "scatter", 
             mode = "lines+markers", 
             marker = list(size = 4)) %>%
  layout(legend = list(x = 0.1, y = 0.5))
p

#save_html(p, file = "Testgraph.html")
#drive_upload("Testgraph.html")

#to plotly
api_create(p, filename = "ExpChart")
