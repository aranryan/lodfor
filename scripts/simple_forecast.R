require("forecast")
load("output_data/out_str_us_m.Rdata")
outf_str_us_m <- out_str_us_m

h <- 30
a <- "1987-01-01"
b <- "2014-12-01"
c <- paste(a, b, sep="::")
c

cityl <- c("totus") #, "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")
segl <- c("demd") #, "occ", "adr", "revpar", "supd") 


Can't seem to get this to work right now
my issues seems to be trying to merge things back onto the original xts object
not really sure what's the best approach. should I be creating an xts object
with just the series I need and then forecasting all of those and then somehow 
pulling them all back together?
might be better to try to create a function? or at least ta


for(n in cityl){
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    series_sa <- paste(n,"_",s, "_sa", sep="")
    series_sf <- paste(n,"_",s, "_sf", sep="")
    print(seriesn)
    
    # uses the variable name to select a specific vector
    temp <- outf_str_us_m[,series_sa]
    temp <- temp[c]
    print(head(temp))
    print(tail(temp))
    fcast1 <- forecast(temp,h=h)$mean
    plot(forecast(temp,h=h))
    print(head(fcast1))
    
    print("got here1")
    
    temp2 <- zooreg(1:30, start = as.yearmon("2014-12-01"), frequency = 12)
    temp3 <- as.Date(index(temp2))
    print(head(temp3))
    temp4 <- xts(fcast1, temp3)
    print(head(temp4))
    print(tail(temp4))
    print(head(temp))
    
    print("got here2")
    temp4 <- rbind(temp, temp4)
    plot(temp4, main=seriesn)
    
    print(tail(temp4))
    print("got here3")
    
    # I previously had a comma before series_sa but got errors
    # I removed it and the error went away. not sure why
    outf_str_us_m[,series_sa] <- NULL
    outf_str_us_m <- merge(outf_str_us_m, temp4)
    print("got here4")
    outf_str_us_m[seriesn] <- outf_str_us_m[,series_sa] * outf_str_us_m[,series_sf]
}
}

tail(temp4)
tail(outf_str_us_m$totus_demd_sa)
head(outf_str_us_m$totus_demd_sa)

outf_str_us_m$totus_demd_sa <- NULL
outf_str_us_m <- merge(outf_str_us_m, temp4)
outf_str_us_m[,totus_demd_sa] <- temp4

head(outf_str_us_m)
tail(outf_str_us_m)
plot(outf_str_us_m$totus_demd)

plot(outf_str_us_m$totus_demd_sa, type='l',
xlim=as.POSIXct(c("2012-01-01","2015-12-01")))

# writes csv versions of the output files
write.zoo(outf_str_us_m, file="output_data/outf_str_us_m.csv", sep=",")
# saves Rdata versions of the output files
save(outf_str_us_m, file="output_data/outf_str_us_m.Rdata")

rm(out_str_us_m)
