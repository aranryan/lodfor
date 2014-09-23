library(forecast)
load("~/Project/R projects/lodfor/output_data/out_m_xts_us.Rdata")
outf_m_xts_us <- out_m_xts_us

h <- 24
a <- "1987-01-01"
b <- "2014-08-01"
c <- paste(a, b, sep="::")
c

cityl <- c("totus", "upmus") #, "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")
segl <- c("demd", "occ", "adr", "revpar", "supd") 

for(n in cityl){
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    series_sa <- paste(n,"_",s, "_sa", sep="")
    series_sf <- paste(n,"_",s, "_sf", sep="")
    print(seriesn)
    
    # uses the variable name to select a specific vector
    temp <- out_m_xts_us[,series_sa]
    temp <- temp[c]
    head(temp)
    tail(temp)
    fcast1 <- forecast(temp,h=h)$mean
    plot(forecast(temp,h=h))
    head(fcast1)
    
    temp2 <- zooreg(1:24, start = as.yearmon("2014-09-01"), frequency = 12)
    temp3 <- as.Date(index(temp2))
    head(temp3)
    temp4 <- xts(fcast1, temp3)
    head(temp4)
    tail(temp4)
    head(temp)
    temp4 <- rbind(temp, temp4)
    plot(temp4)
    
    tail(temp4)
    outf_m_xts_us[,series_sa] <- temp4
    
    outf_m_xts_us[,seriesn] <- outf_m_xts_us[,series_sa] * outf_m_xts_us[,series_sf]

}
}

head(outf_m_xts_us)
tail(outf_m_xts_us)
plot(outf_m_xts_us$totus_demd)


# tempa <- out_m_xts_us$totus_occ
# temp_sf <- out_m_xts_us$totus_occ_sf
# temp_sa <- out_m_xts_us$totus_occ_sa
# tempc <- tempa/temp_sf
# head(tempa)
# head(temp_sf)
# head(temp_sa)
# head(tempc)
#tempd <- temp_sa * temp_sf
#head(tempd)

# writes csv versions of the output files
write.zoo(outf_m_xts_us, file="output_data/outf_m_us.csv", sep=",")

# saves Rdata versions of the output files
save(outf_m_xts_us, file="output_data/outf_m_xts_us.Rdata")

