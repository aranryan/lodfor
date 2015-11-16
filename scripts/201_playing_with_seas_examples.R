## Not run: 

data(holiday)  # dates of Chinese New Year, Indian Diwali and Easter
easter

### use of genhol

# 10 day before Easter day to one day after, quarterly data:
genhol(easter, start = -10, end = 1, frequency = 4)
genhol(easter, frequency = 2)  # easter is allways in the first half-year

# centering for overall mean or monthly calendar means
genhol(easter, center = "mean")
genhol(easter, center = "calendar")

### replicating X-13's built-in Easter adjustment

# built-in
m1 <- seas(x = AirPassengers,
           regression.variables = c("td1coef", "easter[1]", "ao1951.May"),
           arima.model = "(0 1 1)(0 1 1)", regression.aictest = NULL,
           outlier = NULL, transform.function = "log", x11 = "")
summary(m1)
inspect(m1)
out(m1)
monthplot(m1)
monthplot(m1, choice = "irregular")

pacf(resid(m1))
spectrum(diff(resid(m1)))
plot(density(resid(m1)))
qqnorm(resid(m1))

identify(m1)

# user defined variable
ea1 <- genhol(easter, start = -1, end = -1, center = "calendar")

# regression.usertype = "holiday" ensures that the effect is removed from
# the final series.
m2 <- seas(x = AirPassengers,
           regression.variables = c("td1coef", "ao1951.May"),
           xreg = ea1, regression.usertype = "holiday",
           arima.model = "(0 1 1)(0 1 1)", regression.aictest = NULL,
           outlier = NULL, transform.function = "log", x11 = "")
summary(m2)

all.equal(final(m2), final(m1), tolerance = 1e-06)


# with genhol, its possible to do sligtly better, by adjusting the length
# of easter from Friday to Monday:

ea2 <- genhol(easter, start = -2, end = +1, center = "calendar")
m3 <- seas(x = AirPassengers,
           regression.variables = c("td1coef", "ao1951.May"),
           xreg = ea2, regression.usertype = "holiday",
           arima.model = "(0 1 1)(0 1 1)", regression.aictest = NULL,
           outlier = NULL, transform.function = "log", x11 = "")
summary(m3)


### Chinese New Year

data(seasonal)
data(holiday)  # dates of Chinese New Year, Indian Diwali and Easter

# de facto holiday length: http://en.wikipedia.org/wiki/Chinese_New_Year
cny.ts <- genhol(cny, start = 0, end = 6, center = "calendar")

m1 <- seas(x = imp, xreg = cny.ts, regression.usertype = "holiday", x11 = "",
           regression.variables = c("td1coef", "ls1985.Jan", "ls2008.Nov"),
           arima.model = "(0 1 2)(0 1 1)", regression.aictest = NULL,
           outlier = NULL, transform.function = "log")
summary(m1)

# compare to identical no-CNY model
m2 <- seas(x = imp, x11 = "",
           regression.variables = c("td1coef", "ls1985.Jan", "ls2008.Nov"),
           arima.model = "(0 1 2)(0 1 1)", regression.aictest = NULL,
           outlier = NULL, transform.function = "log")
summary(m2)

ts.plot(final(m1), final(m2), col = c("red", "black"))

# modeling complex holiday effects in Chinese imports
# - positive pre-CNY effect
# - negative post-CNY effect
pre_cny <- genhol(cny, start = -6, end = -1, frequency = 12, center = "calendar")
post_cny <- genhol(cny, start = 0, end = 6, frequency = 12, center = "calendar")
m3 <- seas(x = imp, x11 = "",
           xreg = cbind(pre_cny, post_cny), regression.usertype = "holiday",
           x11 = list())
summary(m3)


### Indian Diwali (thanks to Pinaki Mukherjee)

# adjusting Indian industrial production
m4 <- seas(iip,
           x11 = "",
           xreg = genhol(diwali, start = 0, end = 0, center = "calendar"),
           regression.usertype = "holiday"
)
summary(m4)

# without specification of 'regression.usertype', Diwali effects are added
# back to the final series
m5 <- seas(iip,
           x11 = "",
           xreg = genhol(diwali, start = 0, end = 0, center = "calendar")
)

ts.plot(final(m4), final(m5), col = c("red", "black"))

# plot the Diwali factor in Indian industrial production
plot(series(m4, "regression.holiday"))



# collect data
dta <- list(fdeaths = fdeaths, mdeaths = mdeaths)
# loop over dta
ll <- lapply(dta, function(e) try(seas(e, x11 = "")))
# list failing models
is.err <- sapply(ll, class) == "try-error"
ll[is.err]
# return final series of successful evaluations
do.call(cbind, lapply(ll[!is.err], final))


# say I had a ts object with a couple series
str(fdeaths)
ak <- merge(fdeaths = as.zoo(fdeaths), mdeaths = as.zoo(mdeaths))
ak <- as.ts(ak)
ak

# this worked across those series
ll <- lapply(ak, function(e) try(seas(e, x11 = "")))
# list failing models
is.err <- sapply(ll, class) == "try-error"
ll[is.err]
# return final series of successful evaluations
asa <- do.call(cbind, lapply(ll[!is.err], final))

# convert to xts
asa <- as.xts(af)
plot(asa$fdeaths)


