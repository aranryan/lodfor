library(zoo)
library(reshape2)
library(ggplot2)

n <- "totus" # "washingtondc"
m <-  "demd" # "occ", "adr", "revpar", "supd", "schanger") 

load("output_data/ushist_q.Rdata")


temp <- ushist_q #out_str_m

series <- temp[ , paste(n, "_", m, sep="")]
series_sa <- temp[ , paste(n, "_", m,  "_sa", sep="")]
series_sf <- temp[ , paste(n, "_", m, "_sf", sep="")]

autoplot(series_sa)

names(series) <- c("series")
names(series_sa) <- c("series_sa")
names(series_sf) <- c("series_sf")
names(series_irreg) <- c("series_irreg")


df1 <- merge(series, series_sa, series_sf, series_irreg)
df1 <- window(df1, end = as.Date("2014-08-01"))
head(df1)
tail(df1)

df2 <- data.frame(time=time(df1), df1)
head(df2)
tail(df2)
df2$year <- year(df2$time)
df2$month <- month(df2$time)
head(df2)
tail(df2)
plot(df2$year)

# multiplying irregular component times seasonal
df2 <- mutate(df2, series_irreg = series_irreg * series_sf)

head(df2)
tail(df2)

df2$time <- NULL
df2m <- melt(df2, id.vars = c("year", "month"))
df2m[1:4,]
p1 <- ggplot(df2m, aes(x = year, y = value, group=variable)) +
  geom_point(data=df2m[df2m[,"variable"]=="series_irreg",],size=I(2),alpha=I(0.6)) +
  geom_point(data=df2m[df2m[,"variable"]=="series_sf",],size=I(2),alpha=I(0.6)) +
  geom_line(data=df2m[df2m[,"variable"]=="series_sf",],size=I(1),alpha=I(0.5)) 
p1
pout <- p1 + facet_grid(. ~ month) + 
  xlab(paste("year:",min(df2m$year),"to", max(df2m$year))) +
  scale_color_manual(values=c("#666666", "#FF3300", "#0033FF" ))
pout
min(df3$year)
head(df3$year)
head(df3)

p1 <- ggplot(out_str_m, aes(anaheim_demd))+ 
  geom_point(data=dataset)




