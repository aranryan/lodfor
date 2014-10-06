<<<<<<< HEAD
>>>>>>> new_idea
# tried out a new idea
# these two data frames are the working data frames and become the outputs
out_str_m <- lodus_m
out_str_q <- lodus_q
# this is new idea
#cityl <- c("totus") #, "upsus", "upmus") #, "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")

cityl <-  c("washingtondc") #c("anaheim", "atlanta", "boston", "chicago", "dallas", "denver", 
#"detroit", "ecous", "houston", "indus", "lalongbeach", "luxus", "miami", 
#"midus", "minneapolis", "nashville", "neworleans", "newyork", "norfolk",
#"oahu", "orlando", "philadelphia", "phoenix", "sandiego", "sanfrancisco",
#"seattle", "stlouis", "tampa", "upmus", "upsus", "upuus", "totus", "washingtondc")

# list for seasonal adjustment
measl <- c("demd", "occ") #, "adr", "revpar", "supd") 

###############
#
# setting up a matrix that is FALSE for series that should be skipped
# during the adjustment loop
# have monthly and quarterly versions

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
head(adjmat_m)

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

#experimenting with mutate_each
# time <- index(out_str_m)
# head(time)
# temp_b <- data.frame(out_str_m)
# temp_b <- select(temp_b, starts_with("washingtondc"), ends_with("_demd"))
# temp_b <- cbind(temp_b,time)
# head(temp_b)
# temp_b <- mutate_each(temp_b, funs(anr = .*365))
# 
# temp_c <-
# temp_b %>%
#   mutate_each(funs(min(., na.rm=TRUE), max(., na.rm=TRUE)), matches("_demd_sa"))
# head(temp_c)
# 
# temp_c <-
#   temp_b %>%
#   mutate_each(funs(min(., na.rm=TRUE), max(., na.rm=TRUE)), matches("_demd_sa"))
# head(temp_c)



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
rm(temp_a, tempdata, tempdata_fct, tempdata_sa, tempdata_sf)
rm(cityl, freq, mp, n, newseries, plt_start, s, measl, seriesn, start)
rm(temp, temp_names, tempdata_ts, tempdate_m, tempdate_q, tempseries)
rm(term)
rm(units)
