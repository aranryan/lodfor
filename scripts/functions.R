
# names this as a code chunk so I can run it from knitr
## @knitr variablesXY

require("rmarkdown")
require("knitr")
require("dplyr")
require("tidyr")
require("tframe")
require("tframePlus")
require("lubridate")
require("stringr")
require("dplyr")
require("reshape2")
require("ggplot2")
require("scales")


#############################
#
# sets a theme
# requires the grid package
#
require(grid)

theme_jack <- function (base_size = 12, base_family = "") {
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    theme(                                  #text=element_text(family="Lato Light", size=14),
      panel.grid.major.x=element_blank(),
      panel.grid.minor.x=element_blank(),
      panel.grid.minor.y=element_blank(),
      panel.grid.major.y=element_line(colour="#ECECEC", size=0.5, linetype=1),
      axis.ticks.y=element_blank(),
      panel.background=element_blank(),
      legend.title=element_blank(),
      legend.key=element_rect(fill="white", colour = "white"),
      legend.key.size=unit(1.5, "cm"),
      legend.text=element_text(size=16),
      axis.title=element_text(size=10),
      axis.text=element_text(color="black",size=13)
    )
}

##########################
#
# converts units to millions, taking a column of a dataframe as input

units_millions <- function(col) {
  col/1000000
}


##########################
#
# seasonally adjust a series 
# arguments series
# output a data frame containing the seasonal factor and the seasonally adjusted series


seasonal_ad <- function (x,
                        meffects = c("const", "easter[8]", "thank[5]"), 
                        qeffects = c("const", "easter[8]")) {
  #stores the name
  holdn <- names(x)
  print(holdn)
  # trims the NAs from the series
  x <- na.trim(x)
  # this series y is used in the output, just outputs the original series
  y <- x
  
  # http://stackoverflow.com/questions/15393749/get-frequency-for-ts-from-and-xts-for-x12
  freq <- switch(periodicity(x)$scale,
                 daily=365,
                 weekly=52,
                 monthly=12,
                 quarterly=4,
                 yearly=1)
  plt_start <- as.POSIXlt(start(x))
  start <- c(plt_start$year+1900,plt_start$mon+1)
  print(start)
  
  # creates a time series object using start date and frequency
  # declared it as a global object by using <<- because I couldn't figure out
  # how to handle environments. It seems like the issue I was having is that
  # I define the seasonal_ad function, but then when it tries to run the 
  # seas function within that it is referrring to a different environment 
  # and can't seem to find the object that I want to give as an argument to 
  # seas. This is a temporary fix. Long term I should figure out how to handle
  # so that I'm not defining a global object from within the function, but 
  # should be fine for now.
  temp_seasonal_a <<- ts(as.numeric(x), start=start, frequency=freq)
  
  print(head(temp_seasonal_a))
  print(str(temp_seasonal_a))
  print(freq)
  if (freq == '12') regressvar <<- meffects
  if (freq == '4') regressvar <<- qeffects
  print(regressvar)
  print("checking")
  print(head(temp_seasonal_a))
  print(str(temp_seasonal_a))
  
  mp <- seas(temp_seasonal_a,
             transform.function = "log",
             regression.aictest = NULL,
             regression.variables = regressvar, #c("const", "easter[8]", "thank[3]"),
             identify.diff = c(0, 1),
             identify.sdiff = c(0, 1),
             forecast.maxlead = 30, # extends 30 quarters ahead
             x11.appendfcst = "yes", # appends the forecast of the seasonal factors
             dir = "output_data/" 
  )
  #inspect(mp)
  # removes series that is no longer needed
  # doesn't seem to work, maybe because I don't understand environments
  # rm(temp_seasonal_a)
  
  # grabs the seasonally adjusted series
  tempdata_sa <- series(mp, c("d11")) # seasonally adjusted series
  tempdata_sf <- series(mp, c("d16")) # seasonal factors
  tempdata_fct <- series(mp, "forecast.forecasts") # forecast of nonseasonally adjusted series
  tempdata_irreg <- series(mp, c("d13")) # final irregular component
  
  # creates xts objects
  tempdata_sa <- as.xts(tempdata_sa)
  tempdata_sf <- as.xts(tempdata_sf)
  # in the following, we just want the forecast series, not the ci bounds
  # I had to do in two steps, I'm not sure why
  tempdata_fct <- as.xts(tempdata_fct) 
  tempdata_fct <- as.xts(tempdata_fct$forecast) 
  tempdata_irreg <- as.xts(tempdata_irreg)
  
  # names the objects
  names(tempdata_sa) <- paste(holdn,"_sa",sep="") 
  names(tempdata_sf) <- paste(holdn,"_sf",sep="") 
  names(tempdata_fct) <- paste(holdn,"_fct",sep="") 
  names(tempdata_irreg) <- paste(holdn,"_irreg",sep="") 
  
  # merges the adjusted series onto the existing xts object with the unadjusted
  # series
  out_sa <- merge(y, tempdata_sa, tempdata_sf, tempdata_fct, tempdata_irreg)
  return(out_sa)
}


##########################
#
# skip seasonal adjustment but still output series that are 
# the same format as what would be exported by the seasonal 
# adjustment function
# in other words copy the unadjusted series as the
# seasonally adjusted, create seasonal factors equal to 1
# and create a temporary fct series


skip_seasonal_ad <- function (x) {

  # stores the name
  holdn <- names(x)
  print(holdn)
  # trims the NAs from the series
  x <- na.trim(x)
  # sets up a variable with the end of the historical data
  # and then the start of the forecast in the month after
  end <- end(x)
  library(lubridate)
  d <- ymd(end) 
  d <- d + months(1)
  startd <- as.Date(d)
  startd
  
  # this series y is used in the output, just outputs the original series
  y <- x
  
  tempdata_sa <- y
  # seasonal factor is unadjusted series divided by adjusted
  # though in this case that's just 1
  tempdata_sf <- y/y

  # just out of habit, forecast the seasonally adjusted series
  # which is just the nsa series anyway
  tempdata_fct <- forecast(tempdata_sa,h=30)$mean
  plot(tempdata_fct)
  head(tempdata_fct)
  tail(y)
  # start forecast in the month after
  temp2 <- zooreg(1:30, start = as.yearmon(startd), frequency = 12)
  temp3 <- as.Date(index(temp2))
  temp4 <- xts(tempdata_fct, temp3)
  head(temp4)
  tail(temp4)
  tempdata_fct <- rbind(y, temp4)
  plot(tempdata_fct)
  # converts the forecast to an nsa version (even though it's the same)
  tempdata_fct <- tempdata_fct * tempdata_sf
  
  # creates xts objects
  tempdata_sa <- as.xts(tempdata_sa)
  tempdata_sf <- as.xts(tempdata_sf)
  tempdata_fct <- as.xts(tempdata_fct)
  # names the objects
  names(tempdata_sa) <- paste(holdn,"_sa",sep="") 
  names(tempdata_sf) <- paste(holdn,"_sf",sep="") 
  names(tempdata_fct) <- paste(holdn,"_fct",sep="") 
  
  # merges the adjusted series onto the existing xts object with the unadjusted
  # series
  out_sa <- merge(y, tempdata_sa, tempdata_sf, tempdata_fct)
  
return(out_sa)
}

#########################
#
# aggregates, or converts, from monthly to quarterly
#
# I based this on the as.quarterly function that is in
# the tframePlus package
# I set it up so you have to give a type of aggregation
# it works for type=sum or type=mean
# The ts line is basically converting a series from xts
# to ts, because the ts works as an input to as.quarterly
# One reason that I believe I needed to set this up was
# that I want to be able to run it accross columns of an xts
# object, which one can't typically do with apply.
# also, the aggregate.zoo function will sum up the months
# to a quarterly value even if the last month is missing, for 
# example:
#tempc_m <- opcl_m$totusoprms
#tempc_q <- aggregate(tempc_m, as.yearqtr, sum)
#tempc_q <- xts(tempc_q)
# so this is what I came up with
m_to_q=function(x, type){
  a_q <- as.quarterly(
    ts(as.numeric(x), frequency = 12, start = c(year(start(x)), month(start(x)))), 
    FUN=type,
    na.rm=TRUE) # remove nas, helpful for vapply as we can anticipate length
  return(a_q)
}
# as an example of using this function is the steps I had in 
# load_str_openclose, which are as follows
# start <- as.yearqtr((start(opcl_m)))
#h <- zooreg(vapply(opcl_m, m_to_q, FUN.VALUE = 
#                     numeric(floor(nrow(opcl_m)/3)), 
#                   type="sum"), start=start, frequency=4)
#opcl_q <- xts(h)
#indexClass(opcl_q) <- c("Date")
#

# a couple examples of as.quarterly for reference
# z <- ts(1:10, start = c(1999,2), frequency=4)
# z
# as.annually(z) 
# as.annually(z, na.rm=TRUE)
# 
# z <- ts(1:30, start = c(1999,2), frequency=12)
# z
# as.annually(z) 
# as.annually(z, na.rm=TRUE)
# as.quarterly(z) 
# as.quarterly(z, na.rm=TRUE)

# similar for conversion to annual
q_to_a=function(x, type){
  a_a <- as.annually(
    ts(as.numeric(x), frequency = 4, start = c(year(start(x)), month(start(x)))), 
    FUN=type,
    na.rm=FALSE)
  return(a_a)
}

#######################
#
# takes a quarterly xts object with multiple columns and converts to annual 
# need to give the type of conversion as argument, for example could do
# b <- q_to_a_xts(suma, type="sum")
# this function uses the q_to_a function that I've defined above, but then
# applys it to all of the columns of a xts object
q_to_a_xts=function(x, type){
start <- as.Date((start(x)))
start <- as.numeric(format(start(x), "%Y"))
h <- zooreg(vapply(x, q_to_a, FUN.VALUE = 
                     numeric(floor(nrow(x)/4)), 
                   type=type),  start=start, frequency=1)
# at this point it has a four digit year as the index
# but I wanted to format as a date with the start date of the year
h <- zooreg(h, order.by=as.Date(paste(index(h),"-01-01", sep="")))
h <- xts(h)
  return(h)
}

#######################
#
# creating indexes

# creates an index of a quarterly xts or maybe zoo series
index_q=function(x, index_year){
  start_index <- as.Date(paste(index_year,"-01-01",sep=""))
  end_index <- as.Date(paste(index_year,"-10-01",sep=""))
  temp_mean <- mean(window(x, start=start_index, end=end_index))
  x_index <- (x / temp_mean)*100
  return(x_index)
}

# runs across a quarterly xts object to create an index of each series
index_q_xts=function(x, index_year){
  start <- as.Date((start(x)))
  h <- zooreg(vapply(x, index_q, FUN.VALUE = 
                       numeric(nrow(x)), 
                     index_year=index_year))  
  h <- zooreg(h, order.by=index(x))
  h <- xts(h)
  return(h)
}


# creates an index of a _monthly_ xts or maybe zoo series
index_m=function(x, index_year){
  start_index <- as.Date(paste(index_year,"-01-01",sep=""))
  end_index <- as.Date(paste(index_year,"-12-01",sep=""))
  temp_mean <- mean(window(x, start=start_index, end=end_index))
  x_index <- (x / temp_mean)*100
  return(x_index)
}

########################33
#
# functions for plots
#

# adds the title
plot_title_1=function(plot, grtitle, footnote){
  grobframe <- arrangeGrob(plot, ncol=1, nrow=1,
                           main = textGrob(grtitle, x=0, hjust=0, vjust=0.5, 
                                           gp = gpar(fontsize=16, fontface="bold")),
                           sub = textGrob(footnote, x=0, hjust=0, vjust=0.1, 
                                          gp = gpar(fontface="italic", fontsize=8)))
  grid.newpage()
  grid.draw(grobframe)
}



####################
#
# ending that might help with issue in knitr

## @knitr plotXY