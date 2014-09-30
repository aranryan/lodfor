

#############################
#
# sets a theme
# requires the grid package
#
library(grid)

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
                        meffects = c("const", "easter[8]", "thank[3]"), 
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
  # removes series that is no longer needed
  # doesn't seem to work, maybe because I don't understand environments
  # rm(temp_seasonal_a)
  
  # grabs the seasonally adjusted series
  tempdata_sa <- series(mp, c("d11")) # seasonally adjusted series
  tempdata_sf <- series(mp, c("d16")) # seasonal factors
  tempdata_fct <- series(mp, "forecast.forecasts") # forecast of nonseasonally adjusted series
  
  # creates xts objects
  tempdata_sa <- as.xts(tempdata_sa)
  tempdata_sf <- as.xts(tempdata_sf)
  # in the following, we just want the forecast series, not the ci bounds
  # I had to do in two steps, I'm not sure why
  tempdata_fct <- as.xts(tempdata_fct) 
  tempdata_fct <- as.xts(tempdata_fct$forecast) 
  
  # names the objects
  names(tempdata_sa) <- paste(holdn,"_sa",sep="") 
  names(tempdata_sf) <- paste(holdn,"_sf",sep="") 
  names(tempdata_fct) <- paste(holdn,"_fct",sep="") 
  
  # merges the adjusted series onto the existing xts object with the unadjusted
  # series
  out_sa <- merge(y, tempdata_sa, tempdata_sf, tempdata_fct)
  return(out_sa)
}
