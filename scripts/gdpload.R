
library(stringr)
library(plyr) #Hadley said if you load plyr first it should be fine
library(dplyr)
library(reshape2)
library(ggplot2)
library(zoo)
library(xts)
library(lubridate)
#library(forecast) # added so I could use monthdays() which also works for quarters
library(seasonal)
Sys.setenv(X13_PATH = "C:/Aran Installed/x13as")
checkX13()


cl <- c("character", "numeric", "numeric", "numeric") 
gdp_q <- read.zoo("~/Project/R projects/lodging graphs/input_data/gdp.csv", 
                    format = "%m/%d/%Y", header = TRUE, sep=",", colClasses=cl,  index.column = 1) 
gdp_q <- as.xts(gdp_q)
head(gdp_q)
str(gdp_q)

# converts from quarterly to monthly using a spline. 
# If I update, I may need to extend the refdates series from 441 months to more



refdates <- as.yearmon(1987+ seq(0,441)/12)
refdates <- as.Date(refdates)
refdates
gdp_m <- na.spline(gdp_q, xout=refdates)
plot(gdp_m)
head(gdp_m)

write.zoo(gdp_m, file="output_data/gdp_m.csv", sep=",")
