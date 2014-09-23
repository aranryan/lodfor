# in the following yearmon is a class for representing monthly data
# I used it because I found a way to use that format in reading the data
# would have liked to avoid it, as I later conver it with as.Date
f <- function(x) as.yearmon(format(x, nsmall = 2), "%Y%m")

opens_m <- read.zoo("input_data/usopens.csv", header = TRUE, FUN = f , sep=",")
head(opens_m)
opens_m <- rename(opens_m, c("PROPS" = "totusopprop", "ROOMS" = "totusoprms"), warn_missing = TRUE)
opens_m <- as.xts(opens_m)
tempa <- as.Date(index(opens_m))
index(opens_m) <- tempa

closes_m <- read.zoo("input_data/uscloses.csv", header = TRUE, FUN = f , sep=",")
head(closes_m)
closes_m <- rename(closes_m, c("PROPS" = "totusclprop", "ROOMS" = "totusclrms"), warn_missing = TRUE)
closes_m <- as.xts(closes_m)
tempa <- as.Date(index(closes_m))
index(closes_m) <- tempa
rm(tempa)

# combine opens and closes
opcl_m <- merge(opens_m, closes_m)
rm(opens_m, closes_m)

# ensure there aren't any missing months
# this works by creating a new series going from the start to the end without
# any missing months, and then merging that on
# there should be some missing months due to the closes series
# these should appear as a count of NAs in summary
rng <- range(time(opcl_m))
temp <- zoo(1:1, seq(rng[1], rng[2], by = "month"))
opcl_m <- merge(opcl_m, zoo(, seq(rng[1], rng[2], by = "month")))
summary(opcl_m)

# fills NAs with zeros 
opcl_m <- na.fill(opcl_m, c(0))
plot(opcl_m$totusoprms)
plot(opcl_m$totusclrms)
head(opcl_m$totusclrms)

summary(opcl_m)
rm(f)
