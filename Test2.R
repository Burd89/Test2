# library import ----
library(rjson)
library(dplyr)
library(googledrive)
library(htmltools)
library(plotly)

# import data ----

drive_auth(email = TRUE)

drive_download("TestData.csv", type = "csv", overwrite = TRUE)
expDF1 <- read.csv("TestData.csv")
expDF1$X <- NULL
expDF1$time <- as.Date(expDF1$time)

# web scraping and updating data ----

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

# uploading data ----

write.csv(expDF1, file = "TestData.csv")

drive_rename("TestData.csv", name = "TestData2.csv")
drive_upload("TestData.csv")

# data pretreatment for graphing ----
maxExpDf <- aggregate(expDF1$points, by = list(expDF1$name), max)
y_min <- min(maxExpDf[,2])
#maxExpDf[maxExpDf$x == y_min, maxExpDf[,2]]
maxExpDf <- maxExpDf[which.min(maxExpDf$x), ]

expDF4 <- expDF1 %>% filter(expDF1$name == "Ari Bombari")
expDF4$level <- floor(expDF4$level/3*2)
expDF4$points <- 50/3 * (expDF4$level ** 3 - 6 * expDF4$level ** 2 + 17 * expDF4$level - 12)
expDF4$name <- "Minimum Exp Share Range"
expDF4$voc <- "na"
expDF4$rank <- 1
#expDF1 <- rbind(expDF1, expDF4)

#expDF3 <- expDF1 %>% filter(expDF1$name == as.character(maxExpDf$Group.1[[1]]))
#expDF3$level <- floor(expDF3$level/2*3)
#expDF3$points <- 50/3 * (expDF3$level ** 3 - 6 * expDF3$level ** 2 + 17 * expDF3$level - 12)
#expDF3$name <- "Maximum Exp Share Range"
#expDF3$voc <- "na"
#expDF3$rank <- 1
#expDF1 <- rbind(expDF1, expDF3)

expDF5 <- aggregate(expDF1$level, by = list(expDF1$time), min)
expDF5 <- filter(expDF5, as.Date(expDF5$Group.1) > as.Date("2019-10-23"))
expDF5$x <- floor(expDF5$x/2*3+1)
expDF5$points <- 50/3 * (expDF5$x ** 3 - 6 * expDF5$x ** 2 + 17 * expDF5$x - 12)

# plotting ----

p <- plot_ly(expDF1, 
             x = as.Date(expDF1$time), 
             y = expDF1$points, 
             text = paste("Level", expDF1$level), 
             color = expDF1$name, 
             type = "scatter", 
             mode = "lines+markers", 
             marker = list(size = 4)) %>%
  add_trace(x = as.Date(expDF5$Group.1), 
            y = expDF5$points, 
            type = 'scatter', 
            mode = 'lines',
            inherit = FALSE, 
            line = list(color = 'rgba(144,238,144,1)'),
            #showlegend = FALSE, 
            text = paste("Level", expDF5$x - 1),
            name = 'Maximum Exp Share Range') %>%
  add_trace(x = as.Date(expDF4$time), 
            y = expDF4$points, 
            type = 'scatter', 
            mode = 'lines',
            text = paste("Level", expDF4$level),
            fill = 'tonexty',
            inherit = FALSE,
            fillcolor='rgba(144,238,144,0.2)', 
            line = list(color = 'rgba(144,238,144,1)'),
            #showlegend = FALSE, 
            name = 'Minimum Exp Share Range') %>%
  layout(legend = list(x = 0.1, y = 0.5))

p



#save_html(p, file = "Testgraph.html")
#drive_upload("Testgraph.html")

# uploading plot ----

api_create(p, filename = "ExpChart")
