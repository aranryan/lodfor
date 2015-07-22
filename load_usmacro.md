---
title: "load oef macro"
author: "Tourism Economics"
date: "Wednesday, October 15, 2014"
output: html_document
---

As an input, this expects a csv file. This csv file can be created using the
select file that I've set up and the OE macro model.
Also, I've modified it to pull FRED data using a quandl package.


```r
#sets up to later shorten data based on current date 
cur_year <- year(Sys.time())
end_year <- cur_year +15
end_year <- round(end_year,-1) -1
end_date <- paste(end_year,"-10-01",sep="")
```



```r
# require("stringr")
# require("dplyr")
# require("reshape2")
# require("zoo")
# require("xts")
# require("lubridate")
# require("ggplot2")

require("quantmod")

fname <- c("input_data/LODFOR_OEF_USMACRO_2015_04_09.csv")
temp <- read.csv(fname, header=TRUE, stringsAsFactors=FALSE)
```

```
## Warning in file(file, "rt"): cannot open file 'input_data/
## LODFOR_OEF_USMACRO_2015_04_09.csv': No such file or directory
```

```
## Error in file(file, "rt"): cannot open the connection
```

```r
# sets up column names
temp_names <- colnames(temp)
# removes periods in column names
temp_names <- gsub(".", "", temp_names, fixed = TRUE) 
# changes part of column names
temp_names <- tolower(temp_names)
temp_names <- gsub("xus", "us", temp_names) 
temp_names <- gsub("xca", "can", temp_names) 
temp_names <- gsub("xmx", "mex", temp_names) 

# replaces the existing column names
colnames(temp) <- temp_names

# works on the date column to get into a date format
# more difficult than I would have liked
hold <- temp[,1]
hold <- gsub("01$", " Q1", hold) 
hold <- gsub("02$", " Q2", hold) 
hold <- gsub("03$", " Q3", hold) 
hold <- gsub("04$", " Q4", hold) 
temp[,1] <- as.yearqtr(hold) 
head(temp)
```

```
##            us_gdp
## 1980-01-01     NA
## 1980-04-01     NA
## 1980-07-01     NA
## 1980-10-01     NA
## 1981-01-01     NA
## 1981-04-01     NA
```

```r
temp$dates <- format(temp$dates, format="%Y Q%q")
```

```
## Warning in merge.xts(..., all = all, fill = fill, suffixes = suffixes): NAs
## introduced by coercion
```

```r
temp$dates <- as.yearqtr(temp$dates)
# finally gets this to date format
temp$dates <- as.Date(temp$dates)
```

```
## Error in as.Date.default(temp$dates): do not know how to convert 'temp$dates' to class "Date"
```

```r
str(temp)
```

```
## An 'xts' object on 1980-01-01/2029-10-01 containing:
##   Data: num [1:200, 1:2] NA NA NA NA NA NA NA NA NA NA ...
##  - attr(*, "dimnames")=List of 2
##   ..$ : NULL
##   ..$ : chr [1:2] "us_gdp" "dates"
##   Indexed by objects of class: [Date] TZ: UTC
##   xts Attributes:  
##  NULL
```

```r
# much of the data is in character format
# this step converts to numeric and overwrites it
tempa <- temp[,2:ncol(temp)]
tempb <- data.matrix(tempa)
# could have also used sapply I believe
# tempb <- sapply(tempa, as.numeric )
temp[,2:ncol(temp)] <- tempb


#creates zoo object then xts object
temp1 <- read.zoo(temp)
```

```
## Error in read.table(file, ...): 'file' must be a character string or connection
```

```r
class(temp1)
```

```
## Error in eval(expr, envir, enclos): object 'temp1' not found
```

```r
temp1 <- as.xts(temp1, frequency=4)
```

```
## Error in as.xts(temp1, frequency = 4): object 'temp1' not found
```

```r
head(temp1)
```

```
## Error in head(temp1): error in evaluating the argument 'x' in selecting a method for function 'head': Error: object 'temp1' not found
```

```r
oe_usmac_q <- temp1
```

```
## Error in eval(expr, envir, enclos): object 'temp1' not found
```

```r
# shortens data based on end date established at start of script
oe_usmac_q <- window(oe_usmac_q, end = end_date)
```

A few plots
![plot of chunk plots](figure/plots-1.png) ![plot of chunk plots](figure/plots-2.png) ![plot of chunk plots](figure/plots-3.png) ![plot of chunk plots](figure/plots-4.png) ![plot of chunk plots](figure/plots-5.png) ![plot of chunk plots](figure/plots-6.png) 

```
##             us_gdp us_gdp_cagr
## 2013-01-01 3884.60  0.02740747
## 2013-04-01 3901.65  0.01767243
## 2013-07-01 3944.98  0.04516773
## 2013-10-01 3979.05  0.03499526
## 2014-01-01 3957.93 -0.02106276
## 2014-04-01 4002.60  0.04591485
## 2014-07-01 4051.40  0.04966745
## 2014-10-01 4073.68  0.02217946
## 2015-01-01 4087.91  0.01404601
## 2015-04-01 4117.88  0.02964957
## 2015-07-01 4146.21  0.02780431
## 2015-10-01 4175.95  0.02900144
```

Load FRED data

```
## Warning in download.file(paste(FRED.URL, "/", Symbols[[i]], "/",
## "downloaddata/", : downloaded length 12483 != reported length 200
```

```
## Warning in download.file(paste(FRED.URL, "/", Symbols[[i]], "/",
## "downloaddata/", : downloaded length 5991 != reported length 200
```

```
## Warning in download.file(paste(FRED.URL, "/", Symbols[[i]], "/",
## "downloaddata/", : downloaded length 8958 != reported length 200
```

```
## [1] "FEDFUNDS" "GDPPOT"   "USRECQ"
```

```
## Warning in loop_apply(n, do.ply): Removed 62 rows containing missing values
## (geom_path).
```

![plot of chunk fred_data](figure/fred_data-1.png) 

Cleans up

```r
rm(temp, temp1, tempa, fname, hold, temp_names)
```

```
## Warning in rm(temp, temp1, tempa, fname, hold, temp_names): object 'temp1'
## not found
```


Writing out files


```r
# writes csv versions of the output files
write.zoo(oe_usmac_q, file="output_data/oe_usmac_q.csv", sep=",")
```

```
## Warning in file(file, ifelse(append, "a", "w")): cannot open file
## 'output_data/oe_usmac_q.csv': No such file or directory
```

```
## Error in file(file, ifelse(append, "a", "w")): cannot open the connection
```

```r
# saves Rdata versions of the output files
save(oe_usmac_q, file="output_data/oe_usmac_q.Rdata")
```

```
## Warning in gzfile(file, "wb"): cannot open compressed file 'output_data/
## oe_usmac_q.Rdata', probable reason 'No such file or directory'
```

```
## Error in gzfile(file, "wb"): cannot open the connection
```

