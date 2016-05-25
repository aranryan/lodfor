library(zoo)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tempdisagg)

# create annual example series
a <- as.numeric(c("100", "110", "111"))
b <- as.Date(c("2000-01-01", "2001-01-01", "2002-01-01"))
z_a <- zoo(a, b); z_a

# current approach using na.spline in zoo package
end_z <- as.Date(as.yearqtr(end(z_a))+ 3/4)
z_q <- na.spline(z_a, xout = seq(start(z_a), end_z, by = "quarter"), method = "hyman")

# result, with first quarter equal to annual value
c <- merge(z_a, z_q); c

# convert back to annual using aggregate in zoo package 
# At this point I would want both series to be equal, but they aren't. 
d <- aggregate(c, as.integer(format(index(c),"%Y")), mean, na.rm=TRUE); d

# Approach 1
yr <- format(time(c), "%Y")
c$z_q_adj <- ave(coredata(c$z_q), yr, FUN = function(x) x - mean(x) + x[1]); c

# simple plot
dat <- c%>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date)
ggplot(data=dat, aes(x=date, y=value, group=variable, color=variable)) +
  geom_line() +
  geom_point() +
  theme(legend.position=c(.7, .4)) + 
  geom_point(data = subset(dat,variable == "z_a"),  colour="red", shape=1, size=7)


###########

z_a <- ts(c(100, 110, 111), start = 2000)
z_a
z_q <- predict(td(z_a ~ 1, method = "denton-cholette", conversion = "average"))
z_q

z_a <- as.zoo(z_a)
z_q <- as.zoo(z_q)
c_1 <- merge(z_a, z_q); c_1


tapply(z_q, floor(time(z_q)), mean)

dat <- c_1 %>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date)
ggplot(data=dat, aes(x=date, y=value, group=variable, color=variable)) +
  geom_line() +
  geom_point() +
  theme(legend.position=c(.7, .4)) + 
  geom_point(data = subset(dat,variable == "z_a"),  colour="red", shape=1, size=7)

############

c$z_q_amean <- ave(coredata(c$z_q), yr, FUN = function(x) mean(x))
c$z_q_a <- ave(coredata(c$z_q), yr, FUN = function(x) x[1])
c$z_q_x <- ave(coredata(c$z_q), yr, FUN = function(x) x)
c



c$z_q_a <- ave(coredata(c$z_q), yr, FUN = function(x) x[2])
c$z_q_amin <- ave(coredata(c$z_q), yr, FUN = function(x) x[-1])
c$z_q_x <- ave(coredata(c$z_q), yr, FUN = function(x) mean(x[-1]) +x[1])
c$z_q_adj <- ave(coredata(c$z_q), yr, FUN = function(x) c(x[1], x[-1] - mean(x[-1]) +x[1]))



e <- aggregate(c, as.integer(format(index(c),"%Y")), mean, na.rm=TRUE); e

plot(c$z_q_adj)


dat <- c%>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date)

ggplot() +   geom_line(data = dat, aes(x = date, y = value, color=variable), size = .7)


ggplot(data=dat, aes(x=date, y=value, group=variable, color=variable)) +
  geom_line() +
  geom_point() +
  theme(legend.position=c(.7, .4)) 