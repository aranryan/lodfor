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
library(forecast)

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

##########################################################3
# unit conversion for monthly and quarterly
# based on series names in the monthly data frame
#
#

# list for unit conversions (dividing by 1 million)
units <- c("supt", "demt", "supd", "demd", "rmrevt")

# set up to do the unit version on any series that match the terms 
# in the units list

# names of all the series
temp_names <- names(lodus_m)

# list of all the series that match the mneuomonics in units
temp_units <- vector()
for(term in units){
  # searches across temp_names for those items that start with the search term
  # the (^) symbol means starts with
  # based it on the following thread
  # http://r.789695.n4.nabble.com/grep-with-search-terms-defined-by-a-variable-td2311294.html
  # though the thread also mentioned a loopless alternative
  # also this was useful reference on strings
  #http://gastonsanchez.com/Handling_and_Processing_Strings_in_R.pdf
  terma <- paste("_",term,sep="")
  temp <- grep(paste(terma,sep=""),temp_names, value=TRUE)
  temp_units <- c(temp_units, temp)
}

# unit conversion
# applies a function to each specified series, overwriting the original
print("doing unit conversion, monthly and quarterly")
for(n in temp_units){
  seriesn <- paste(n, sep="")
  # the units_millions function is one I defined
  lodus_m[,seriesn] <- units_millions(lodus_m[,seriesn])
  lodus_q[,seriesn] <- units_millions(lodus_q[,seriesn])
}

###################
#
# cleans up
#
rm(n, seriesn, temp, temp_names, temp_units, term, terma, units)
