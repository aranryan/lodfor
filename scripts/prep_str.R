# this is going to be the output file
# going to add the adjusted series to it
out_str_m <- lodus_m
out_str_q <- lodus_q

#cityl <- c("totus") #, "upsus", "upmus") #, "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")

cityl <-  c("philadelphia") #c("anaheim", "atlanta", "boston", "chicago", "dallas", "denver", 
#"detroit", "ecous", "houston", "indus", "lalongbeach", "luxus", "miami", 
#"midus", "minneapolis", "nashville", "neworleans", "newyork", "norfolk",
#"oahu", "orlando", "philadelphia", "phoenix", "sandiego", "sanfrancisco",
#"seattle", "stlouis", "tampa", "upmus", "upsus", "upuus", "totus", "washingtondc")



# list for seasonal adjustment
# "supdaily" I was having issues running seasonal adjustment on supply, so set it aside
segl <- c("demd", "occ", "adr", "revpar", "supd") 

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
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    print(seriesn)
    temp <- seasonal_ad(out_str_m[,seriesn], meffects =  c("const", "easter[8]")) 
    # drops the original series
    # I tried other ways to refer to seriesn but couldn't get it to work
    # this works because seriesn is the first column
    temp <- temp[,2:4]
    temp_out_m <- merge(temp, temp_out_m)
  }}

temp_out_m$dummy <- NULL
out_str_m <- merge(temp_out_m,out_str_m)
head(out_str_m)

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
rm(cityl, freq, mp, n, newseries, plt_start, s, segl, seriesn, start)
rm(temp, temp_names, tempdata_ts, tempdate_m, tempdate_q, tempseries)
rm(term)
rm(units)
