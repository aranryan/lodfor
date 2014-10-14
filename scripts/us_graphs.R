

## Creates a few US graphs
load("~/Project/R projects/lodfor/output_data/out_str_q_us.Rdata")

library(zoo)
library(reshape2)
library(ggplot2)


xts1 <- out_str_q_us
xts1 <- window(xts1, end = as.Date("2014-08-01"))

df1 <- data.frame(time=time(xts1), xts1)

head(df1)
tail(df1)
str(df1)
df1$year <- year(df1$time)
df1$month <- month(df1$time)

df2 <- df1
$df2$time <- NULL

df2m <- melt(df2, id.vars = c("time"))
df2m[1:4,]
temp <- filter(df2m,variable == "totus_demd_sa" | variable == "totus_demd")
p1 <- ggplot(temp, aes(x = time, y = value, color = variable)) +
 geom_line() 
p1
