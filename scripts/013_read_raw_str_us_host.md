# create_ushist
Tourism Economics  

Setup

```r
#read_chunk('~/Project/R projects/lodfor/scripts/functions.R')
#source('~/Project/R projects/lodfor/scripts/functions_combined.R')
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(readr, warn.conflicts=FALSE)
```


```r
fpath <- c("~/Project/R projects/lodfor")

# reference file to use in converting market names to shorter abbreviations
colc <- c(rep("character",4))
fname <- paste0(fpath, "/reference/host_str_simp.csv")
host_str_simp <- read.csv(fname, header = TRUE, sep = ",", colClasses=colc)

# imports list of MSAs based on Census and corresponding BLS codes
colc <- rep("character", 10)
fname <- paste0(fpath, "/input_data/m_cen_blsces.csv")
m_cen_blsces <- read.csv(fname, head=TRUE, colClasses=colc) 
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
fname <- paste0(fpath, "/input_data/Host - Top Markets Data 2016-11-04 - AR modified.csv")
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
row1 <- stringr::str_replace(row1,"/","-")
# earlier version in which row1 was a data frame
#row1 <- lapply(row1[1,], function(x) str_replace(x,"/","-"))
a <- as.character(row1[4:length(row1)]) %>%
  stringr::str_replace("/","-") %>%
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
# data_1 <- read.csv(fname, header = FALSE, sep = ",", skip = 8,
#                     na.strings = c("", "na", "NA", "0", "/0"), stringsAsFactors=FALSE)
# switched this over to read_csv because later on columns in character format were an issue
data_1 <- read_csv(fname, col_names = FALSE, col_types = NULL, 
                    na = c("", "na", "NA", "0", "/0"), skip = 8)
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   X1 = col_character(),
##   X2 = col_character(),
##   X3 = col_character(),
##   X4 = col_character(),
##   X5 = col_character()
## )
```

```
## See spec(...) for full column specifications.
```

```r
data_2 <- data_1 %>%
    select(X1,X2, num_range("X",5:ncol(.)))
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
  mutate(area_sh = ifelse(hoststr_simp == "Oakland", "oklca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "San Francisco and San Jose, CA", "sfjca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui, HI", "khlhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Oahu, HI", "hnlhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui and Oahu, HI", "mouhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "United States", "usxxx", area_sh)) %>%
  # manually sets country field for those areas
  # could be done more simply with a lookup table of some type but at least
  # this is parallel with above
  mutate(country = ifelse(hoststr_simp == "Orange County", "usa", country)) %>%
  mutate(country = ifelse(hoststr_simp == "Oakland", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "San Francisco and San Jose, CA", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Maui, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Oahu, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "Maui and Oahu, HI", "usa", country)) %>%
  mutate(country = ifelse(area_name_simp == "United States", "usa", country)) 
  
  # pause to create a list of area_sh codes and the corresponding market names
  mkt_list <- data_4 %>%  
   select(area_sh, area_name_simp, area_name_cen) %>%
   distinct(., area_sh)

data_5 <- data_4 %>%
  select(date, var, seg_text, area_sh, country, value) %>%
  mutate(seg_abrev = ifelse(seg_text == "All Chain Scales","tot", 
               ifelse(seg_text == "Upscale & Above","upa", 
               ifelse(seg_text == "Luxury","lux", 
               ifelse(seg_text == "Upper Upscale", "upu", 
               ifelse(seg_text == "Upscale","ups", 
                      NA)))))) %>%
  mutate(seggeo = paste(seg_abrev, area_sh, country, sep="_")) %>%
  select(date, seggeo, var, value)

# spreads into series in columns
data_6 <- data_5 %>%
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
data_7 <- Filter(function(x)!all(is.na(x)), data_6)

raw_str_us_host <- data_7 %>%
 # select(1:12) %>%
  data.frame() %>%
  read.zoo() %>%
  lapply(., FUN=na.contiguous) %>%
  do.call("merge", .) %>%
  data.frame(date=time(.), .)
```

# save output

```r
# saves Rdata version of the data
fname <- paste0(fpath, "/output_data/raw_str_us_host.Rdata")
save(raw_str_us_host, file=fname)

fname <- paste0(fpath, "/output_data/mkt_list_host.csv")
write.csv(mkt_list, file=fname, row.names=FALSE)
```
