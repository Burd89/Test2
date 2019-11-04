library(rjson)
library(dplyr)
library(googledrive)

drive_download("TestData.csv", type = "csv", overwrite = TRUE)
#expDF1 <- data.frame()
expDF1 <- read.csv("TestData.csv")


url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Knight.json"
expDF <- jsonlite::fromJSON(url)
expDF <- data.frame(expDF$highscores$data)
expDF["time"] <- Sys.time()
expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Wats Ke Burd"))

url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Druid.json"
expDF <- jsonlite::fromJSON(url)
expDF <- data.frame(expDF$highscores$data)
expDF["time"] <- Sys.time()
expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Po Ni Teel"))

url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Sorcerer.json"
expDF <- jsonlite::fromJSON(url)
expDF <- data.frame(expDF$highscores$data)
expDF["time"] <- Sys.time()
expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Don Teeltje"))

url = "https://api.tibiadata.com/v2/highscores/Faluna/Experience/Paladin.json"
expDF <- jsonlite::fromJSON(url)
expDF <- data.frame(expDF$highscores$data)
expDF["time"] <- Sys.time()
expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == "Ari Bombari"))

write.csv(expDF1, file = "TestData.csv")

drive_upload("TestData.csv")

#test

drive_download("TestData.csv", type = "csv", overwrite = TRUE)
#expDF1 <- data.frame()
expDF1 <- read.csv("TestData.csv")

vocation <- c("Knight","Sorcerer","Druid","Paladin")
names <- c("Wats Ke Burd","Don Teeltje","Po Ni Teel","Ari Bombari")

options(timeout= 4000000)

for (i in 1:4) {
  url = paste("https://api.tibiadata.com/v2/highscores/Faluna/Experience/",vocation[i],".json", sep = "")
  expDF <- jsonlite::fromJSON(url)
  expDF <- data.frame(expDF$highscores$data)
  expDF["time"] <- Sys.time()
  expDF1 <- rbind(expDF1, expDF %>% filter(expDF$name == names[i]))
}

write.csv(expDF1, file = "TestData.csv")

drive_upload("TestData.csv")
