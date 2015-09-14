# load oef macro
Tourism Economics  
Wednesday, October 15, 2014  


Setup

```r
#read_chunk('~/Project/R projects/lodfor/scripts/functions.R')
source('~/Project/R projects/lodfor/scripts/functions.R')
#setwd("./output_data/")
```



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
if (!require(quantmod)) {
  install.packages("quantmod")
  require(quantmod)
}

fpath <- c("~/Project/R projects/lodfor/")

# when kniting from the button, I either needed the full path or to add "../" 
# in front of each
#load(paste(fpath, "output_data/ushist_m.Rdata", sep=""))


fname <- c("../input_data/LODFOR_OEF_USMACRO_2015_09_14.csv")
# the check.names piece fixes the issueof the column names coming in with
# quotes and spaces due to the Oxford file format that is visible when 
# you open the csv file in notepad
temp <- read.csv(fname, header=TRUE, sep=",", check.names=FALSE) 
# puts column names into lower case
names(temp) <- tolower(names(temp))
# trims leading and trailing whitespace
names(temp) <- str_trim(names(temp))
colnames(temp)
```

```
##  [1] "dates"      "us_ipnr"    "us_if"      "us_gdp"     "us_rlg"    
##  [6] "us_psh"     "us_smp"     "us_rrx"     "us_cd"      "us_domd"   
## [11] "us_inrs"    "us_ipde"    "us_rcorp"   "us_iconstr" "us_popnipa"
## [16] "us_pop"     "us_popw"    "us_et"      "us_yhat"    "us_wc"     
## [21] "us_cpi"     "us_pc"      "us_pgdp"    "us_eci"     "us_pedy"   
## [26] "us_penwall" "us_cogtp"   "us_conw"    "us_up"      "mx_gdp"    
## [31] "mx_cpi"     "mx_pc"      "ca_gdp"     "ca_cpi"     "ca_pc"     
## [36] "us_gfnc"    "us_gf"      "wd_wpo_wti" "jp_rxd"     "wd_gdp"    
## [41] "wd_gdpppp"  "wd_gdp$&"
```

```r
# changes $ and & in the wd_gdp$& column name
col_temp <- colnames(temp) %>%
  gsub("\\$&", "nusd", .)
colnames(temp) <- col_temp

# works on the date column to get into a date format
# more difficult than I would have liked
temp <- temp %>%
  rename(date = dates) %>%
  mutate(date = gsub("01$", "-01-01", date)) %>%
  mutate(date = gsub("02$", "-04-01", date)) %>%
  mutate(date = gsub("03$", "-07-01", date)) %>%
  mutate(date = gsub("04$", "-10-01", date)) %>%
  mutate(date = as.Date(date))

temp_2 <- temp %>%
  gather(geovar, value, -date) %>%
  mutate(geovar = as.character(geovar)) %>%
  # I think this separates on the first occurance of the underscore, 
  # not all occurances
  separate(geovar, c("geo", "variable"), sep = "\\_", extra="merge") 

oe_usmac_q <- temp_2 %>%
  # renames "if" to "ifix" because r doesn't like "if" as a variable name
  mutate(variable = ifelse(variable == "if", "ifix", variable)) %>%
  # also, I didn't like wpo_wti as a variable name, because it has the 
  # underscore, which is distracting, and may cause trouble
  mutate(variable = ifelse(variable == "wpo_wti", "wpowti", variable)) %>%
  # changes codes for canada, mexico and japan
  mutate(geo = ifelse(geo == "ca", "can", geo)) %>%
  mutate(geo = ifelse(geo == "mx", "mex", geo)) %>%
  # recombine the geo and var
  mutate(geovar = paste(geo, variable, sep="_")) %>%
  select(-geo, -variable) %>%
  spread(geovar, value) %>%
  read.zoo() %>%
  xts(frequency=4)

# shortens data based on end date established at start of script
oe_usmac_q <- window(oe_usmac_q, end = end_date)
```

###A few plots
![](040_load_usmacro_files/figure-html/plots-1.png) ![](040_load_usmacro_files/figure-html/plots-2.png) ![](040_load_usmacro_files/figure-html/plots-3.png) ![](040_load_usmacro_files/figure-html/plots-4.png) ![](040_load_usmacro_files/figure-html/plots-5.png) ![](040_load_usmacro_files/figure-html/plots-6.png) 

```
##             us_gdp  us_gdp_cagr
## 2013-01-01 3864.30  0.019094840
## 2013-04-01 3875.05  0.011174020
## 2013-07-01 3903.60  0.029797883
## 2013-10-01 3940.38  0.038224294
## 2014-01-01 3931.23 -0.009256141
## 2014-04-01 3975.38  0.045684765
## 2014-07-01 4017.20  0.042747656
## 2014-10-01 4037.85  0.020720671
## 2015-01-01 4044.32  0.006424773
## 2015-04-01 4081.07  0.036845702
## 2015-07-01 4101.48  0.020155127
## 2015-10-01 4131.13  0.029231464
```

###Load FRED data

```
## Warning in download.file(url, destfile, method, quiet, mode, cacheOK,
## extra): downloaded length 12534 != reported length 200
```

```
## Warning in download.file(url, destfile, method, quiet, mode, cacheOK,
## extra): downloaded length 5991 != reported length 200
```

```
## Warning in download.file(url, destfile, method, quiet, mode, cacheOK,
## extra): downloaded length 8958 != reported length 200
```

```
## [1] "FEDFUNDS" "GDPPOT"   "USRECQ"
```

```
## Warning: Removed 62 rows containing missing values (geom_path).
```

![](040_load_usmacro_files/figure-html/fred_data-1.png) 

###Writing out files

```r
# writes csv versions of the output files
write.zoo(oe_usmac_q, file="../output_data/oe_usmac_q.csv", sep=",")
# saves Rdata versions of the output files
save(oe_usmac_q, file="../output_data/oe_usmac_q.Rdata")
```

