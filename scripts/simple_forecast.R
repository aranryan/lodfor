require("forecast")
load("output_data/out_str_m_us.Rdata")
outf_str_m_us <- out_str_m_us

h <- 30
a <- "1987-01-01"
b <- "2014-09-01"
c <- paste(a, b, sep="::")
c

cityl <- c("totus", "indus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous")
segl <- c("demd", "occ", "adr", "revpar", "supd") 

for(n in cityl){
  for(s in segl){
    seriesn <- paste(n,"_",s, sep="")
    series_sa <- paste(n,"_",s, "_sa", sep="")
    series_sf <- paste(n,"_",s, "_sf", sep="")
    print(seriesn)
    
    # uses the variable name to select a specific vector
    temp <- outf_str_m_us[,series_sa]
    temp <- temp[c]
    print(head(temp))
    print(tail(temp))
    fcast1 <- forecast(temp,h=h)$mean
    plot(forecast(temp,h=h))
    print(head(fcast1))
    
    print("got here1")
    
    temp2 <- zooreg(1:30, start = as.yearmon("2014-10-01"), frequency = 12)
    temp3 <- as.Date(index(temp2))
    print(head(temp3))
    temp4 <- xts(fcast1, temp3)
    print(head(temp4))
    print(tail(temp4))
    print(head(temp))
    
    print("got here2")
    temp4 <- rbind(temp, temp4)
    plot(temp4)
    
    print(tail(temp4))
    print("got here3")
    
    outf_str_m_us[,series_sa] <- temp4
    print("got here4")
    outf_str_m_us[,seriesn] <- outf_str_m_us[,series_sa] * outf_str_m_us[,series_sf]
}
}
head(outf_str_m_us)
tail(outf_str_m_us)
plot(outf_str_m_us$totus_demd)

# writes csv versions of the output files
write.zoo(outf_str_m_us, file="output_data/outf_str_m_us.csv", sep=",")
# saves Rdata versions of the output files
save(outf_str_m_us, file="output_data/outf_str_m_us.Rdata")

rm(out_str_m_us)
