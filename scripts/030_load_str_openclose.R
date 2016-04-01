
library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(seasonal, warn.conflicts=FALSE)

# in the following yearmon is a class for representing monthly data
# I used it because I found a way to use that format in reading the data
# would have liked to avoid it, as I later conver it with as.Date
f <- function(x) as.yearmon(format(x, nsmall = 2), "%Y%m")
fname_opens <- c("input_data/coopopen2016-03-17.txt")
fname_closes <- c("input_data/coopclose2016-03-17.txt")

# handles opens

# old approach to reading input when it was in Excel
# opens_m <- read.xlsx(fname, sheetName="cooptotopen", startRow=3,colIndex =1:3,
#                      header = TRUE) %>%
#   rename(totus_opprop = PROPS, totus_oprms = ROOMS) %>%
#   # filters to drop rows where the YYYYM ends in 13
#   # or starts with TOTAL, and then also drops the NA row that appears at bottom
#   filter(!grepl("13$", YYYYMM)) %>%
#   filter(!grepl("^TOTAL", YYYYMM)) %>%
#   na.omit(opens_m) %>%
#   read.zoo(header = TRUE, FUN = f , sep=",") %>%
#   xts()

opens_m <- read.delim(fname_opens, stringsAsFactors=FALSE) %>%
  rename(seg=Segment, date=Open.Date, opprop = Props, oprms = Rooms) %>%
  # filters to drop rows where the date ends in 13
  # or starts with TOTAL, and then also drops the NA row that appears at bottom
  filter(!grepl("13$", date)) %>%
  filter(!grepl("^TOTAL", date)) %>%
  na.omit(opens_m) %>%
  # changing segments to codes
  mutate(seg=as.factor(seg)) %>%
  mutate(seg = gsub("United States", "totus", seg)) %>%
  mutate(seg = gsub("Luxury Chains", "luxus", seg)) %>%
  mutate(seg = gsub("Upper Upscale Chains", "upuus", seg)) %>%
  mutate(seg = gsub("Upscale Chains", "upsus", seg)) %>%
  mutate(seg = gsub("Upper Midscale Chains", "upmus", seg)) %>%
  mutate(seg = gsub("Midscale Chains", "midus", seg)) %>%
  mutate(seg = gsub("Economy Chains", "ecous", seg)) %>%
  mutate(seg = gsub("Independents", "indus", seg)) 

a <- reshape2::melt(opens_m, id=c("date","seg"), na.rm=FALSE)
a$variable <- paste(a$seg, "_", a$variable, sep='')
a$seg <- NULL
opens_m <- a %>%
  # splits based on the second column
  # uses function to read in date
  read.zoo(header = TRUE, FUN = f , sep=",", split = 2) %>%
  xts()

  # changes the format of the index from month-year to date
  tempa <- as.Date(index(opens_m))
  index(opens_m) <- tempa

# handles closes
closes_m <- read.delim(fname_closes, stringsAsFactors=FALSE) %>%
  rename(seg=Segment, date=Open.Date, clprop = Props, clrms = Rooms) %>%
  # filters to drop rows where the date ends in 13
  # or starts with TOTAL, and then also drops the NA row that appears at bottom
  filter(!grepl("13$", date)) %>%
  filter(!grepl("^TOTAL", date)) %>%
  na.omit(closes_m) %>%
  # changing segments to codes
  mutate(seg=as.factor(seg)) %>%
  mutate(seg = gsub("United States", "totus", seg)) %>%
  mutate(seg = gsub("Luxury Chains", "luxus", seg)) %>%
  mutate(seg = gsub("Upper Upscale Chains", "upuus", seg)) %>%
  mutate(seg = gsub("Upscale Chains", "upsus", seg)) %>%
  mutate(seg = gsub("Upper Midscale Chains", "upmus", seg)) %>%
  mutate(seg = gsub("Midscale Chains", "midus", seg)) %>%
  mutate(seg = gsub("Economy Chains", "ecous", seg)) %>%
  mutate(seg = gsub("Independents", "indus", seg)) 

a <- reshape2::melt(closes_m, id=c("date","seg"), na.rm=FALSE)
a$variable <- paste(a$seg, "_", a$variable, sep='')
a$seg <- NULL
closes_m <- a %>%
  # splits based on the second column
  # uses function to read in date
  read.zoo(header = TRUE, FUN = f , sep=",", split = 2) %>%
  xts()

# changes the format of the index from month-year to date
tempa <- as.Date(index(closes_m))
index(closes_m) <- tempa

##############
#
# combine opens and closes
opcl_m <- merge(opens_m, closes_m)

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
plot(opcl_m$totus_oprms)
plot(opcl_m$totus_clrms)
head(opcl_m$totus_clrms)
tail(opcl_m$totus_clrms)

plot(opcl_m$upsus_clrms)
plot(opcl_m$upsus_oprms)

summary(opcl_m)
rm(f)

#############################3
#
# creates quarterly by summing monthly
#

# I couldn't use apply because the object is 
# a xts, not a dataframe, see 
# http://codereview.stackexchange.com/questions/39180/best-way-to-apply-across-an-xts-object

# sets up the start of the index that will be used for the quarterly object
# uses vapply to essentially run an apply across the xts object because
# apply doesn't work on an xts object
# for vapply we need to give the expected length in FUN.VALUE and a
# start date and quarterly frequency
# The function that I'm applying to each column is m_to_q, which I wrote, the type="sum"
# is giving the type of aggregation to use in it
start <- as.yearqtr((start(opcl_m)))
h <- zooreg(vapply(opcl_m, m_to_q, FUN.VALUE = 
                     numeric(ceiling(nrow(opcl_m)/3)), 
                     type="sum"), start=start, frequency=4)
# converts to xts
opcl_q <- xts(h)
# changes the format of the index for the xts object from yearqtr to Date
indexClass(opcl_q) <- c("Date")
# if I had just wanted to run on one series, I could do the following
#d <- m_to_q(opcl_m$totus_oprms, type=sum)
#d

tail(opcl_q)

plot(opcl_q$totus_oprms)
plot(opcl_q$totus_clrms)
tail(opcl_q)

out_opcl_q <- opcl_q
out_opcl_m <- opcl_m

########
#
# set up for seasonal adjustment
# just adjusted US opens. need to work on it to get 
# adjustments going for segments sometime

# just did opens, closes wouldn't adjust
segl <- c("tot") #, "lux", "upu", "ups", "upm", "mid", "eco")
segl <- paste(segl, "us_oprms", sep="")
seriesl_m <- segl # "totus_clrms")
seriesl_q <- segl # "totus_clrms")

#########
#
# monthly seasonal adjustment
#
print("monthly")
# creates a blank object with just a dummy series
# this is used to hold the output of each seasonal adjustment
temp_out_m <- xts(order.by=index(out_opcl_m))
temp_out_m <- merge(temp_out_m, dummy=1)
head(temp_out_m)


for(n in seriesl_m){
    seriesn <- n
    print(seriesn)
    
      # if it is to be adjusted then it runs the adjustment function
      temp <- seasonal_ad(out_opcl_m[,seriesn], 
                          meffects =  c("const", "easter[8]", "thank[5]")) 
    # drops the original series
    # I tried other ways to refer to seriesn but couldn't get 
    # it to work this works because seriesn is the first column
    temp <- temp[,2:ncol(temp)]
    temp_out_m <- merge(temp, temp_out_m)
}
temp_out_m$dummy <- NULL
out_opcl_m <- merge(temp_out_m,out_opcl_m)


# a <- out_opcl_m$totus_oprms
# 
# y <- a %>%
#   convertIndex("yearmon")
# temp_seasonal_a <- ts(y, start = start(y), end = end(y), frequency = 12)
# 
# 
# temp_seasonal_a <<- ts(as.numeric(a), start=start, frequency=freq)
# 
# mp <- seas(temp_seasonal_a,
#            transform.function = "log",
#            regression.aictest = NULL,
#            regression.variables = regressvar, #c("const", "easter[8]", "thank[3]"),
#            identify.diff = c(0, 1),
#            identify.sdiff = c(0, 1),
#            forecast.maxlead = 30, # extends 30 quarters ahead
#            x11.appendfcst = "yes", # appends the forecast of the seasonal factors
#            dir = "output_data/" 
# )
# #inspect(mp)
# # removes series that is no longer needed
# # doesn't seem to work, maybe because I don't understand environments
# # rm(temp_seasonal_a)
# 
# # grabs the seasonally adjusted series
# tempdata_sa <- series(mp, "fct") # seasonally adjusted series
# tempdata_sa <- series(mp, c("d11")) # seasonally adjusted series
# tempdata_sf <- series(mp, c("d16")) # seasonal factors
# tempdata_fct <- series(mp, "forecast.forecasts") # forecast of nonseasonally adjusted series
# tempdata_irreg <- series(mp, c("d13")) # final irregular component




#########
#
# quarterly seasonal adjustment
#
print("quarterly")
# creates a blank object with just a dummy series
# this is used to hold the output of each seasonal adjustment
temp_out_q <- xts(order.by=index(out_opcl_q))
temp_out_q <- merge(temp_out_q, dummy=1)
head(temp_out_q)


for(n in seriesl_q){
  seriesn <- n
  print(seriesn)
  
  # if it is to be adjusted then it runs the adjustment function
  temp <- seasonal_ad(out_opcl_q[,seriesn], 
                      qeffects =  c("const", "easter[8]")) 
  # drops the original series
  # I tried other ways to refer to seriesn but couldn't get 
  # it to work this works because seriesn is the first column
  temp <- temp[,2:ncol(temp)]
  temp_out_q <- merge(temp, temp_out_q)
}
temp_out_q$dummy <- NULL
out_opcl_q <- merge(temp_out_q,out_opcl_q)



#################
#
# looking at data a bit
#

# monthly
tail(out_opcl_m)

autoplot.zoo(out_opcl_m$totus_oprms)
autoplot.zoo(out_opcl_m$totus_oprms_sa)

autoplot.zoo(out_opcl_m$totus_clrms)

# quarterly
a <- window(out_opcl_q, start = as.Date("2000-01-01"), end=as.Date("2016-01-01"))
tail(a)

autoplot.zoo(out_opcl_q$totus_oprms)
autoplot.zoo(out_opcl_q$totus_oprms_sa)

autoplot.zoo(out_opcl_q$totus_clrms)


#########################
#
# writing outputs
#

# writes csv versions of the output files
write.zoo(out_opcl_m, file="output_data/out_opcl_m.csv", sep=",")
write.zoo(out_opcl_q, file="output_data/out_opcl_q.csv", sep=",")

# saves Rdata versions of the output files
save(out_opcl_m, file="output_data/out_opcl_m.Rdata")
save(out_opcl_q, file="output_data/out_opcl_q.Rdata")
