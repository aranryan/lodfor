# create_ushist
Tourism Economics  
Thursday, October 16, 2014  

Setup

```r
#read_chunk('~/Project/R projects/lodfor/scripts/functions.R')
source('~/Project/R projects/lodfor/scripts/functions.R')
```

```
## Loading required package: rmarkdown
## Loading required package: knitr
## Loading required package: grid
## Loading required package: xlsx
## Loading required package: rJava
## Loading required package: xlsxjars
## Loading required package: tframe
## Loading required package: tframePlus
## Loading required package: lubridate
## Loading required package: stringr
## Loading required package: scales
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## Loading required package: xts
## Loading required package: seasonal
## 
## seasonal now supports the HTML version of X13, which offers a more
## accessible output via the out() function. For best user experience, 
## download the HTML version from:
## 
##   http://www.census.gov/srd/www/x13as/x13down_pc.html
## 
## and copy x13ashtml.exe to:
## 
##   C:/Aran Installed/x13as
## Loading required package: forecast
## Loading required package: timeDate
## This is forecast 6.1 
## 
## Loading required package: car
## Loading required package: reshape2
## Loading required package: ggplot2
## Loading required package: tidyr
## Loading required package: plyr
## 
## Attaching package: 'plyr'
## 
## The following object is masked from 'package:lubridate':
## 
##     here
## 
## Loading required package: dplyr
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:plyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
## 
## The following objects are masked from 'package:xts':
## 
##     first, last
## 
## The following objects are masked from 'package:lubridate':
## 
##     intersect, setdiff, union
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
## 
## Loading required package: lazyeval
## Loading required package: broom
## Loading required package: assertthat
```

```r
getwd()
```

```
## [1] "C:/Users/Aran/Documents/Project/R projects/lodfor/scripts"
```


```r
# reference file to use in converting market names to shorter abbreviations
colc <- c(rep("character",4))
host_str_simp <- read.csv("../reference/host_str_simp.csv", header = TRUE, sep = ",", colClasses=colc)

# imports list of MSAs based on Census and corresponding BLS codes
colc <- rep("character", 10)
m_cen_blsces <- read.csv("../input_data/m_cen_blsces.csv", head=TRUE, colClasses=colc) 
str(m_cen_blsces)
```

```
## 'data.frame':	392 obs. of  18 variables:
##  $ area_code_cen    : chr  "10180" "10380" "10420" "10500" ...
##  $ area_name_sh     : chr  "abilntx" "agdllpr" "akronoh" "albnyga" ...
##  $ area_sh          : chr  "abltx" "agdpr" "akroh" "albga" ...
##  $ area_name_simp   : chr  "Abilene, TX" "Aguadilla, PR" "Akron, OH" "Albany, GA" ...
##  $ area_name_cen    : chr  "Abilene, TX" "Aguadilla-Isabela, PR" "Akron, OH" "Albany, GA" ...
##  $ states_two       : chr  "TX" "PR" "OH" "GA" ...
##  $ states           : chr  "TX" "PR" "OH" "GA" ...
##  $ area_type_cen    : chr  "Metropolitan Statistical Area" "Metropolitan Statistical Area" "Metropolitan Statistical Area" "Metropolitan Statistical Area" ...
##  $ st_name          : chr  "Texas" "Puerto Rico" "Ohio" "Georgia" ...
##  $ cen_div          : chr  "West South Central" "Not in a Division" "East North Central" "South Atlantic" ...
##  $ cen_reg          : chr  "South" "Not in a Region" "North Central" "South" ...
##  $ area_code_blsces : chr  "10180" "10380" "10420" "10500" ...
##  $ area_name_blsces : chr  "Abilene, TX" "Aguadilla-Isabela-San Sebastian, PR" "Akron, OH" "Albany, GA" ...
##  $ area_type_blsces : chr  "Metropolitan Statistical Area" "Metropolitan Statistical Area" "Metropolitan Statistical Area" "Metropolitan Statistical Area" ...
##  $ area_code_bletnum: chr  "ABIL148" NA "AKRO439" "ALBA513" ...
##  $ area_name_bletnum: chr  "Abilene, TX" NA "Akron, OH" "Albany, GA" ...
##  $ msa_grid_code    : chr  NA NA NA NA ...
##  $ country          : chr  "usa" "usa" "usa" "usa" ...
```

```r
# name of file to read
fname <- c("../input_data/Host - top 20 - ByMarket - 2015-07-27.csv")
```

# load STR data

```r
# first read in the first two rows after skipping 7, and grab the names of the markets and 
# segments from the first row
first1 <- read.csv(fname, header = FALSE, sep = ",", 
                   nrows=1, stringsAsFactors=FALSE, na.strings=c("", "NA"), skip=7)
# row1 is used later as the column names for the data
row1 <- first1 %>%
  select(V1,V2, num_range("V",5:ncol(.))) %>%
  as.character()
row1[1] <- c("seg_text")
row1[2] <- c("geo_text")
row1[3] <- c("var")
row1 <- str_replace(row1,"/","-")
# earlier version in which row1 was a data frame
#row1 <- lapply(row1[1,], function(x) str_replace(x,"/","-"))
a <- as.character(row1[4:length(row1)]) %>%
  str_replace("/","-") %>%
  as.yearmon(., "%Y-%B") %>%
  as.Date() %>%
  as.character()
row1[4:length(row1)] <- a
head(row1)
```

```
## [1] "seg_text"   "geo_text"   "var"        "1987-01-01" "1987-02-01"
## [6] "1987-03-01"
```

```r
#######################
#
# now read in the table without headers

# in the following, made a concious decision to convert cells with zeros to NA.
# while zero could be true, it's could be that there are a small number of hotels 
# and that the data was suppressed for confidentiality reasons
data_1 <- read.csv(fname, header = FALSE, sep = ",", skip = 8,
                    na.strings = c("", "na", "NA", "0", "/0"), stringsAsFactors=FALSE)
data_2 <- data_1 %>%
    select(V1,V2, num_range("V",5:ncol(.)))
# applies the row1 column names prepared above
colnames(data_2) <- row1

# uses apply to remove columns that are NA
# is this dangerous to do, I guess not because there should be at least some
# data for each month
data_3 <- data_2[, !apply(is.na(data_2), 2, all)] 

# gets to a tidy format
data_4 <- data_3 %>%
  mutate(var = ifelse(var == "Available Rooms", "supt", var)) %>%
  mutate(var = ifelse(var == "Rooms Sold", "demt", var)) %>%
  mutate(var = ifelse(var == "Rooms Rev", "rmrevt", var)) %>%
  filter(var == "supt" | var == "demt" | var == "rmrevt") %>%
  gather(date, value, 4:ncol(.)) %>%
  left_join(., host_str_simp, by=c("geo_text" = "hoststr_text")) %>%
  select(date, var, seg_text, area_name_simp, hoststr_simp, value) %>%
  left_join(., m_cen_blsces, by=c("area_name_simp")) %>%
  # manually applies an area_sh code for Orange County and some other Host STR data
  mutate(area_sh = ifelse(hoststr_simp == "Orange County", "orgca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "San Francisco and San Jose, CA", "sfjca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui, HI", "khlhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Oahu, HI", "hnlhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui and Oahu, HI", "mouhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "United States", "usxxx", area_sh)) %>%
  # manually sets country field for those areas
  # could be done more simply with a lookup table of some type but at least
  # this is parallel with above
  mutate(country = ifelse(hoststr_simp == "Orange County", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "San Francisco and San Jose, CA", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Maui, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Oahu, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Maui and Oahu, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "United States", "usa", country)) %>%
  select(date, var, seg_text, area_sh, country, value) %>%
  mutate(seg_abrev = ifelse(seg_text == "All Chain Scales","tot", 
               ifelse(seg_text == "Upscale & Above","upa", 
               ifelse(seg_text == "Luxury","lux", 
               ifelse(seg_text == "Upper Upscale", "upu", 
               ifelse(seg_text == "Upscale","ups", 
                      NA)))))) %>%
  mutate(geo = paste0(area_sh, country)) %>%
  mutate(seggeo = paste(seg_abrev, geo, sep="_")) %>%
  select(date, seggeo, var, value)

# spreads into series in columns
data_5 <- data_4 %>%
  mutate(segvar = paste(seggeo,var,sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)
```

# extracts the longest contigous portions of each series
works as follows:
starts with dataframe with series in columns
reads to zoo, and then applies the zoo function na.contiguous to each 
column, returning a list in which each object of the list is a series
then does do.call merge which zoo recognizes and uses to merge together
the series as a single zoo object respecting dates, and then convert that
to a dataframe with a date column
another consideration would be to run na.spline or na.approx first which
has an argument to set the max number of NAs to fill, so that might 
be a good way to fill small holes

```r
# drops columns that are all NA
# haven't figured out a less complex way to write this, but there must be
data_5 <- data_5[, !apply(is.na(data_5), 2, all)]

# first had to make it numeric, because it was characters for some reason
data_6 <- as.data.frame(sapply(data_5, as.numeric)) 
data_6$date <- data_5$date

raw_str_us_host <- data_6%>%
 # select(1:12) %>%
  read.zoo() %>%
  lapply(., FUN=na.contiguous) %>%
  do.call("merge", .) %>%
  data.frame(date=time(.), .)
```

# save output

```r
# saves Rdata version of the data
save(raw_str_us_host, file="output_data/raw_str_us_host.Rdata")
```
