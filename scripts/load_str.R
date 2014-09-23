library(stringr)
library(plyr) #Hadley said if you load plyr first it should be fine
library(dplyr)
library(reshape2)
library(ggplot2)
#library(zoo)
library(xts)
library(lubridate)
#library(forecast) # added so I could use monthdays() which also works for quarters
library(seasonal)
Sys.setenv(X13_PATH = "C:/Aran Installed/x13as")
checkX13()

########
#
# load STR data
#
cl <- c("NULL", "numeric", "character", "integer")[c(3, 4, 4, 4, 4, rep(2,264))] # columns 2 to 268 are to be numeric class, incld date it's 269
lodus_m <- read.zoo("input_data/lodgeus_str_m.csv", 
   format = "%m/%d/%Y", header = TRUE, sep=",", colClasses=cl, index.column = 1) 
lodus_m <- as.xts(lodus_m)

cl <- c("NULL", "numeric", "character", "integer")[c(3, 4, 4, 4, 4, rep(2,264))] # columns 2 to 22 are to be numeric class
lodus_q <- read.zoo("input_data/lodgeus_str_q.csv", 
  format = "%m/%d/%Y", header = TRUE, sep=",", colClasses=cl, index.column = 1) 
lodus_q <- as.xts(lodus_q)

rm(cl)
