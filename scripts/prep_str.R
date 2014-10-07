
# these two data frames are the working data frames and become the outputs
out_str_m <- lodus_m
out_str_q <- lodus_q

cityl <- c(
  "totus" 
   ,"indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous"
  
   ,"anaheim", "atlanta", "boston", "chicago", "dallas" 
   ,"denver", "detroit", "houston", "lalongbeach", "miami" 
   ,"minneapolis", "nashville", "neworleans", "newyork", "norfolk"
   ,"oahu", "orlando", "philadelphia", "phoenix", "sandiego" 
   ,"sanfrancisco", "seattle", "stlouis", "tampa", "washingtondc"
  )

measl <- c(
  "demd" 
   ,"occ" 
   ,"adr" 
   ,"revpar" 
   ,"supd"
  ) 

###############
#
# setting up a matrix that is FALSE for series that should be skipped
# during the adjustment loop
# have monthly and quarterly versions

#monthly
adjmat_m <- matrix(TRUE, nrow = length(measl), ncol = length(cityl))
colnames(adjmat_m) <- cityl
rownames(adjmat_m) <- measl
head(adjmat_m)
# manually set the cells to skip to FALSE
# first tests to see if a given metro is in the vector using is.element which
# returns true if it's in the vector
if (is.element('anaheim', cityl)){
adjmat_m["supd","anaheim"] <- FALSE
}
if (is.element('neworleans', cityl)){
  adjmat_m["supd","neworleans"] <- FALSE
}
if (is.element('oahu', cityl)){
  adjmat_m["supd","oahu"] <- FALSE
}
if (is.element('sanfrancisco', cityl)){
  adjmat_m["supd","sanfrancisco"] <- FALSE
}
if (is.element('tampa', cityl)){
  adjmat_m["supd","tampa"] <- FALSE
}
head(adjmat_m)

#quarterly
adjmat_q <- matrix(TRUE, nrow = length(measl), ncol = length(cityl))
colnames(adjmat_q) <- cityl
rownames(adjmat_q) <- measl
head(adjmat_q)
# manually set the cells to skip to FALSE
# first tests to see if a given metro is in the vector using is.element which
# returns true if it's in the vector
if (is.element('anaheim', cityl)){
  #adjmat_q["supd","anaheim"] <- FALSE
}
head(adjmat_q)

#########
#
# monthly seasonal adjustment
#
print("monthly")
# creates a blank object with just a dummy series
# this is used to hold the output of each seasonal adjustment
temp_out_m <- xts(order.by=index(out_str_m))
temp_out_m <- merge(temp_out_m, dummy=1)
head(temp_out_m)

for(n in cityl){
  for(s in measl){
    seriesn <- paste(n,"_",s, sep="")
    print(seriesn)
    
    # checking whether there series is to be adjusted
    adjmat_t <- adjmat_m[s, n]
    if (adjmat_t==TRUE) {
      
      # if it is to be adjusted then it runs the adjustment function
      print(paste("yes, adjust ", adjmat_t, sep=""))    
      temp <- seasonal_ad(out_str_m[,seriesn], 
                          meffects =  c("const", "easter[8]", "thank[5]")) 
    }
    # if it isn't to be adjusted then it runs the skip adjustment 
    # function which creates a similar set of outputs
    else {
      print(paste("skip adjusting", seriesn, sep=""))
      temp <- skip_seasonal_ad(out_str_m[,seriesn])
    }
    
    # drops the original series
    # I tried other ways to refer to seriesn but couldn't get 
    # it to work this works because seriesn is the first column
    temp <- temp[,2:ncol(temp)]
    temp_out_m <- merge(temp, temp_out_m)
  } 
}
temp_out_m$dummy <- NULL
out_str_m <- merge(temp_out_m,out_str_m)
head(out_str_m)

# creates a seasonally adjusted annual rate series for demand based on daily
# previously I had a loop that did this
# converts the xts object to a data frame
temp_b <- data.frame(out_str_m)
# sets up the column names I will use
temp_names <- 
  select(temp_b, ends_with("_demd_sa"))
temp_names <- colnames(temp_names)
temp_names <- gsub("_demd_sa", "_demar_sa", temp_names)
head(temp_names)  
# used dplyr piping create the annual rate series
temp_b <- 
  # uses dplyr select to select all columns based on end_with 
  select(temp_b, ends_with("_demd_sa")) %>%
    # uses vapply in base r to multiply each column by 365 to get to annual rate.
  # vapply is apparently similar to sapply but has a pre-specified type of return
  # value so it can be safer and faster to use.
  # http://codereview.stackexchange.com/questions/39180/best-way-to-apply-across-an-xts-object
  vapply(function(col) col * 365, FUN.VALUE = numeric(nrow(temp_b))) %>%
  # puts output back into an xts format based on the time index in certain dataframe
  xts(order.by = time(out_str_m))
# renames columns using vector created previously
colnames(temp_b) <- temp_names
head(temp_b)
out_str_m <- merge(out_str_m, temp_b)
rm(temp_b, temp_names)

# my old loop
# for(term in cityl){
#   print(term)
#   tempseries <- paste(term, "_demd_sa", sep="")
#   print(tempseries)
#   newseries <- paste(term, "_demar_sa", sep="")
#   temp_a <- out_str_m[,tempseries]*365
#   colnames(temp_a) <- newseries
#   out_str_m <- merge(out_str_m, temp_a)
# }

#########
#
# quarterly seasonal adjustment
# just like monthly - with specific changes commented
print("quarterly")
# creates a blank object with just a dummy series
# this is used to hold the output of each seasonal adjustment
temp_out_q <- xts(order.by=index(out_str_q))
temp_out_q <- merge(temp_out_q, dummy=1)
head(temp_out_q)

for(n in cityl){
  for(s in measl){
    seriesn <- paste(n,"_",s, sep="")
    print(seriesn)
    
    # checking whether there series is to be adjusted
    adjmat_t <- adjmat_q[s, n]
    if (adjmat_t==TRUE) {
      
      # if it is to be adjusted then it runs the adjustment function
      print(paste("yes, adjust ", adjmat_t, sep=""))    
      temp <- seasonal_ad(out_str_q[,seriesn], 
                          # took out thanksgiving for quarterly
                          meffects =  c("const", "easter[8]")) 
    }
    # if it isn't to be adjusted then it runs the skip adjustment 
    # function which creates a similar set of outputs
    else {
      print(paste("skip adjusting", seriesn, sep=""))
      temp <- skip_seasonal_ad(out_str_q[,seriesn])
    }
    
    # drops the original series
    # I tried other ways to refer to seriesn but couldn't get 
    # it to work this works because seriesn is the first column
    temp <- temp[,2:ncol(temp)]
    temp_out_q <- merge(temp, temp_out_q)
  } 
}
temp_out_q$dummy <- NULL
out_str_q <- merge(temp_out_q,out_str_q)
head(out_str_q)

# creates a seasonally adjusted annual rate series for demand based on daily
# previously I had a loop that did this
# converts the xts object to a data frame
temp_b <- data.frame(out_str_q)
# sets up the column names I will use
temp_names <- 
  select(temp_b, ends_with("_demd_sa"))
temp_names <- colnames(temp_names)
temp_names <- gsub("_demd_sa", "_demar_sa", temp_names)
head(temp_names)  
# used dplyr piping create the annual rate series
temp_b <- 
  # uses dplyr select to select all columns based on end_with 
  select(temp_b, ends_with("_demd_sa")) %>%
  # uses vapply in base r to multiply each column by 365 to get to annual rate.
  # vapply is apparently similar to sapply but has a pre-specified type of return
  # value so it can be safer and faster to use.
  # http://codereview.stackexchange.com/questions/39180/best-way-to-apply-across-an-xts-object
  vapply(function(col) col * 365, FUN.VALUE = numeric(nrow(temp_b))) %>%
  # puts output back into an xts format based on the time index in certain dataframe
  xts(order.by = time(out_str_q))
# renames columns using vector created previously
colnames(temp_b) <- temp_names
head(temp_b)
out_str_q <- merge(out_str_q, temp_b)
rm(temp_b, temp_names)




################
#
# creates a partial file with just the US and chainscale outputs, no metros
# idea was that would be useful with IHG files
print("preping US output files")

# makes a list of the column names that start with the various segments and US total
# both monthly and quarterly are done with the same loop
uslist<- c("ecous", "indus", "luxus", "midus", "upmus", "upsus", "upuus", "totus")

temp_names <- names(out_str_m)
temp_out <- c("year", "month", "qtr", "days")

for(term in uslist){
  # searches across temp_names for those items that start with the search term
  # the (^) symbol means starts with
  # based it on the following thread
  # http://r.789695.n4.nabble.com/grep-with-search-terms-defined-by-a-variable-td2311294.html
  # though the thread also mentioned a loopless alternative
  # also this was useful reference on strings
  #http://gastonsanchez.com/Handling_and_Processing_Strings_in_R.pdf
  temp_us <- grep(paste("^",term,sep=""),temp_names, value=TRUE)
  temp_out_uslist <- c(temp_out, temp_us)
}

# takes just those columns in out_str_m that are in the list of names
out_str_q_us <- out_str_q[ , temp_out_uslist]
out_str_m_us <- out_str_m[ , temp_out_uslist]
rm(uslist, temp_us, temp_out_uslist)

#########################
#
# writing outputs
#

# writes csv versions of the output files
write.zoo(out_str_m, file="output_data/out_str_m.csv", sep=",")
write.zoo(out_str_q, file="output_data/out_str_q.csv", sep=",")

write.zoo(out_str_m_us, file="output_data/out_str_m_us.csv", sep=",")
write.zoo(out_str_q_us, file="output_data/out_str_q_us.csv", sep=",")

# saves Rdata versions of the output files
save(out_str_m, file="output_data/out_str_m.Rdata")
save(out_str_q, file="output_data/out_str_q.Rdata")

save(out_str_m_us, file="output_data/out_str_m_us.Rdata")
save(out_str_q_us, file="output_data/out_str_q_us.Rdata")

#########################
#
# cleaning up

rm(regressvar, temp_seasonal_a, temp_out_m)
rm(temp_out, lodus_m, lodus_q)
#rm(out_str_m, out_str_m_us, out_str_q, out_str_q_us)
rm(tempdata, tempdata_fct, tempdata_sa, tempdata_sf)
rm(cityl)
rm(temp, temp_names, tempdata_ts, tempdate_m, tempdate_q)
rm(term)
rm(units)
