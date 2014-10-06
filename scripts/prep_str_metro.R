# this is going to be the output file
# going to add the adjusted series to it
out_str_m <- lodus_m
out_str_q <- lodus_q

tempdate_q <- index(lodus_q)
tempdate_q <- as.Date(tempdate_q, "%Y-%m-%d")
tempdate_m <- index(lodus_m)
tempdate_m <- as.Date(tempdate_m, "%Y-%m-%d")

# list of cities/chainscales
cityl <-  c("washingtondc") #c("anaheim", "atlanta", "boston", "chicago", "dallas", "denver", 
#"detroit", "ecous", "houston", "indus", "lalongbeach", "luxus", "miami", 
#"midus", "minneapolis", "nashville", "neworleans", "newyork", "norfolk",
#"oahu", "orlando", "philadelphia", "phoenix", "sandiego", "sanfrancisco",
#"seattle", "stlouis", "tampa", "upmus", "upsus", "upuus", "totus", "washingtondc")

#cityl <- c("totus", "upsus", "upmus") #, "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")

# list for unit conversions (dividing by 1 million)
units <- c("supt", "demt", "supd", "demd", "rmrevt")

# list for seasonal adjustment
# "supdaily" I was having issues running seasonal adjustment on supply, so set it aside

segl <- c("demd", "occ", "adr", "revpar", "supd") 

# unit conversion
# applies a function to each specified series, overwriting the original
print("doing unit conversion, quarterly")
for(n in cityl){
  for(s in units){
    seriesn <- paste(n,"_",s, sep="")
    # the units_millions function is one I defined
    out_str_q[,seriesn] <- units_millions(out_str_q[,seriesn])
  }
}

for(n in cityl){
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    print("quarterly")
    print(seriesn)

      # just to work through one example rather than running the whole loop
      #seriesn <- c("washingtondc_demd")

      # so this is evaluating what's in the seriesn variable
      # puts the series into a variable called tempdata
      # print(lodusq_df[,eval(seriesn)])
      tempdata <- out_str_q[,seriesn]
      # previously had done the line above this way for some reason
      #tempdata <- xts(lodusq_df[,eval(seriesn)], tempdate_q)
 
      # trims the NAs from the series
      tempdata <- na.trim(tempdata)
      
      # http://stackoverflow.com/questions/15393749/get-frequency-for-ts-from-and-xts-for-x12
      freq <- switch(periodicity(tempdata)$scale,
                     daily=365,
                     weekly=52,
                     monthly=12,
                     quarterly=4,
                     yearly=1)
      plt_start <- as.POSIXlt(start(tempdata))
      start <- c(plt_start$year+1900,plt_start$mon+1)
      print(start)
      
      # creates a time series object using start date and frequency
      tempdata_ts <- ts(as.numeric(tempdata), start=start, frequency=freq)
      
      mp <- seas(tempdata_ts,
                 transform.function = "log",
                 regression.aictest = NULL,
                 # for monthly
                 # regression.variables = c("const", "easter[8]", "thank[3]"),
                 # for quarterly
                 regression.variables = c("const", "easter[8]"),
                 identify.diff = c(0, 1),
                 identify.sdiff = c(0, 1),
                 forecast.maxlead = 30, # extends 30 quarters ahead
                 x11.appendfcst = "yes", # appends the forecast of the seasonal factors
                 dir = "output_data/"           
      )
      # grabs the seasonally adjusted series
      tempdata_sa <- series(mp, c("d11")) # seasonally adjusted series
      tempdata_sf <- series(mp, c("d16")) # seasonal factors
      tempdata_fct <- series(mp, c("fct")) # forecast of nonseasonally adjusted series
        
      # creates xts objects
      tempdata_sa <- as.xts(tempdata_sa)
      tempdata_sf <- as.xts(tempdata_sf)
      # in the following, we just want the forecast series, not the ci bounds
      # I had to do in two steps, I'm not sure why
      tempdata_fct <- as.xts(tempdata_fct) 
      tempdata_fct <- as.xts(tempdata_fct$forecast) 
    
      # names the objects
      names(tempdata_sa) <- paste(seriesn,"_sa",sep="") 
      names(tempdata_sf) <- paste(seriesn,"_sf",sep="") 
      names(tempdata_fct) <- paste(seriesn,"_fct",sep="") 
      
      # merges the adjusted series onto the existing xts object with the unadjusted
      # series
      out_str_q <- merge(out_str_q, tempdata_sa, tempdata_sf, tempdata_fct)
    }
}

# creates a seasonally adjusted annual rate series for demand based on daily
for(term in cityl){
  print(term)
  tempseries <- paste(term, "_demd_sa", sep="")
  print(tempseries)
  newseries <- paste(term, "_demar_sa", sep="")
  temp_a <- out_str_q[,tempseries]*365
  colnames(temp_a) <- newseries
  out_str_q <- merge(out_str_q, temp_a)
}

# monthly, just a copy of above with relabeling data frames and adding 
#thanksgiving variable

# unit conversion
# applies a function to each specified series, overwriting the original
print("doing unit conversion, quarterly")
for(n in cityl){
  for(s in units){
    seriesn <- paste(n,"_",s, sep="")
    # the units_millions function is one I defined
    out_str_m[,seriesn] <- units_millions(out_str_m[,seriesn])
  }
}

for(n in cityl){
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    print("monthly")
    print(seriesn)
    
    # just to work through one example rather than running the whole loop
    #seriesn <- c("washingtondc_demd")
    
    # so this is evaluating what's in the seriesn variable
    # puts the series into a variable called tempdata
    # print(lodusq_df[,eval(seriesn)])
    tempdata <- out_str_m[,seriesn]
    
    # trims the NAs from the series
    tempdata <- na.trim(tempdata)
    
    # http://stackoverflow.com/questions/15393749/get-frequency-for-ts-from-and-xts-for-x12
    freq <- switch(periodicity(tempdata)$scale,
                   daily=365,
                   weekly=52,
                   monthly=12,
                   quarterly=4,
                   yearly=1)
    plt_start <- as.POSIXlt(start(tempdata))
    start <- c(plt_start$year+1900,plt_start$mon+1)
    print(start)
    
    # creates a time series object using start date and frequency
    tempdata_ts <- ts(as.numeric(tempdata), start=start, frequency=freq)
    
    mp <- seas(tempdata_ts,
               transform.function = "log",
               regression.aictest = NULL,
               # for monthly
                regression.variables = c("const", "easter[8]", "thank[3]"),
               # for quarterly
               #regression.variables = c("const", "easter[8]"),
               identify.diff = c(0, 1),
               identify.sdiff = c(0, 1),
               forecast.maxlead = 24, # extends 24 months ahead
               x11.appendfcst = "yes", # appends the forecast of the seasonal factors
               dir = "output_data/"           
    )
    # grabs the seasonally adjusted series
    tempdata_sa <- series(mp, c("d11"))
    tempdata_sf <- series(mp, c("d16")) # seasonal factors
    tempdata_fct <- series(mp, c("fct")) # forecast of nonseasonally adjusted series
    
    # not sure what these did
    #trim <- (length(tempdata_sa))
    #trimdate <- tempdate[1:trim]
    #tempdata_sa <- xts(tempdata_sa, trimdate)
    
    # creates an xts object
    tempdata_sa <- as.xts(tempdata_sa)
    tempdata_sf <- as.xts(tempdata_sf)
    # in the following, we just want the forecast series, not the ci bounds
    # I had to do in two steps, I'm not sure why
    tempdata_fct <- as.xts(tempdata_fct) 
    tempdata_fct <- as.xts(tempdata_fct$forecast) 
    
    # names the object
    names(tempdata_sa) <- paste(seriesn,"_sa",sep="")
    names(tempdata_sf) <- paste(seriesn,"_sf",sep="") 
    names(tempdata_fct) <- paste(seriesn,"_fct",sep="") 
    
    # merges the adjusted series onto the existing xts object with the unadjusted
    # series
    out_str_m <- merge(out_str_m, tempdata_sa, tempdata_sf, tempdata_fct)
  }
}
# creates a seasonally adjusted annual rate series for demand based on daily
for(term in cityl){
  print(term)
  tempseries <- paste(term, "_demd_sa", sep="")
  print(tempseries)
  newseries <- paste(term, "_demar_sa", sep="")
  temp_a <- out_str_m[,tempseries]*365
  colnames(temp_a) <- newseries
  out_str_m <- merge(out_str_m, temp_a)
}

# creates a file with just the US and chainscale outputs, no metros
# idea was that would be useful with IHG files

print("preping output files")

# makes a list of the column names that start with the various segments and US total
# both monthly and quarterly are done with the same loop

#cityl <- c("ecous", "indus", "luxus", "midus", "upmus", "upsus", "upuus", "totus")

temp_names <- names(out_str_m)
temp_out <- c("year", "month", "qtr", "days")

for(term in cityl){
  # searches across temp_names for those items that start with the search term
  # the (^) symbol means starts with
  # based it on the following thread
  # http://r.789695.n4.nabble.com/grep-with-search-terms-defined-by-a-variable-td2311294.html
  # though the thread also mentioned a loopless alternative
  # also this was useful reference on strings
  #http://gastonsanchez.com/Handling_and_Processing_Strings_in_R.pdf
  temp <- grep(paste("^",term,sep=""),temp_names, value=TRUE)
  temp_out <- c(temp_out, temp)
}
temp_out
# takes just those columns in out_str_m that are in the list of names
out_str_q_metro <- out_str_q[ , temp_out]
out_str_m_metro <- out_str_m[ , temp_out]

# writes csv versions of the output files
write.zoo(out_str_m_metro, file="output_data/out_m_metro.csv", sep=",")
write.zoo(out_str_q_metro, file="output_data/out_q_metro.csv", sep=",")

# saves Rdata versions of the output files
save(out_str_m_metro, file="output_data/out_str_m_metro.Rdata")
save(out_str_q_metro, file="output_data/out_str_q_metro.Rdata")

rm(temp_out, lodus_m, lodus_q)
rm(out_str_m, out_str_m_metro, out_str_q, out_str_q_metro)
rm(temp_a, tempdata, tempdata_fct, tempdata_sa, tempdata_sf)
rm(cityl, freq, mp, n, newseries, plt_start, s, segl, seriesn, start)
rm(temp, temp_names, tempdata_ts, tempdate_m, tempdate_q, tempseries)
rm(term)
rm(units)
