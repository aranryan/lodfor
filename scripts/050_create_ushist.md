# create_ushist
Tourism Economics  
Thursday, October 16, 2014  

Setup

```r
library(arlodr, warn.conflicts=FALSE)
library(zoo, warn.conflicts=FALSE)
library(xts, warn.conflicts=FALSE)
library(seasonal, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
```

Creates a us historical databank. Combines the STR data with selected macro data and calculates a few series

```r
fpath <- c("~/Project/R projects/lodfor/") 
#macro data
  load(paste(fpath,"output_data/oe_usmac_q.Rdata", sep=""))
# str data
  load(paste(fpath,"output_data/out_str_us_q.Rdata", sep="")) 
  load(paste(fpath,"output_data/out_str_us_m.Rdata", sep=""))

  load(paste(fpath,"output_data/out_str_ihg_mex_q.Rdata", sep="")) 
  load(paste(fpath,"output_data/out_str_ihg_mex_m.Rdata", sep=""))

  load(paste(fpath,"output_data/out_str_ihg_can_q.Rdata", sep="")) 
  load(paste(fpath,"output_data/out_str_ihg_can_m.Rdata", sep=""))
# open close data
  load(paste(fpath,"output_data/out_opcl_q.Rdata", sep=""))
  load(paste(fpath,"output_data/out_opcl_m.Rdata", sep=""))
```

The initial steps do the quarterly databank. Monthly is done further below.

```r
# selects certain series to bring in. Others just stay in macro in case they 
# are needed in future.
temp <- oe_usmac_q %>%
  data.frame(date=time(oe_usmac_q), oe_usmac_q) %>%
  select(date, 
         us_gdp,
         us_ifix,
         us_cd,
         us_iconstr,
         us_popnipa,
         us_popw,
         us_et,
         us_up,
         us_yhat,
         us_pc,
         us_pedy,
         us_penwall,
         us_cogtp,
         us_cpi,
         us_usrecq,
         can_gdp,
         can_cpi,
         can_pc,
         mex_gdp,
         mex_cpi,
         mex_pc
         ) %>%
  read.zoo %>%
  as.xts
head(temp)
```

```
##             us_gdp us_ifix  us_cd us_iconstr us_popnipa us_popw    us_et
## 1980-01-01 1631.22 309.150 59.750    198.181     226754  166762  99862.3
## 1980-04-01 1598.15 286.775 53.300    177.166     227389  167416  98953.3
## 1980-07-01 1595.72 287.925 55.650    180.214     228070  168111  98899.0
## 1980-10-01 1625.30 297.125 57.350    190.966     228689  168694  99498.7
## 1981-01-01 1658.93 301.075 58.975    188.642     229155  169279 100239.0
## 1981-04-01 1646.82 301.225 56.700    189.510     229674  169837 100801.0
##              us_up us_yhat  us_pc us_pedy us_penwall us_cogtp  us_cpi
## 1980-01-01 6.30000 1640.53 42.398 1147.47    9238.63   59.375 79.0333
## 1980-04-01 7.33333 1649.28 43.435 1130.80    9582.46   51.750 81.7000
## 1980-07-01 7.66667 1657.47 44.449 1144.56    9985.12   53.650 83.2333
## 1980-10-01 7.40000 1665.53 45.547 1167.01   10326.50   58.775 85.5667
## 1981-01-01 7.43333 1673.97 46.675 1163.91   10522.40   61.100 87.9333
## 1981-04-01 7.40000 1683.50 47.454 1163.67   10786.20   60.200 89.7667
##            us_usrecq can_gdp can_cpi  can_pc mex_gdp  mex_cpi    mex_pc
## 1980-01-01         0  192198 42.2796 40.4810 1491.85 0.101089 0.0872228
## 1980-04-01         1  191779 43.4352 41.5748 1501.59 0.106925 0.0936615
## 1980-07-01         1  191712 44.6358 42.7220 1534.00 0.113918 0.1038760
## 1980-10-01         0  193866 45.9055 44.0455 1578.43 0.119657 0.1061130
## 1981-01-01         0  198708 47.4281 45.4805 1613.67 0.129351 0.1115770
## 1981-04-01         0  200900 48.9277 46.5727 1655.48 0.137261 0.1193420
```

```r
# merges dataframes. the all.=TRUE piece ensures all the rows
# in the first dataframe are included
ushist_q <- merge(temp, out_str_us_q, all=TRUE) 

######################
#
# indexes everything in ushist_q
#
# ushist_ind_q <- index_q_xts(ushist_q,index_year=2005)
# 
# # look at a graph
# tempa <- ushist_ind_q$totus_occ_sa
# tempb <- ushist_ind_q$upsus_occ_sa
# tempc <- merge(tempa,tempb)
# autoplot(window(tempc, start="2000-01-01", end="2014-10-01"), facets=NULL)

######################
#
# converts some series to real
#

# first index the personal cons price deflator to average 100 in 2014
us_pc_index <- index_q(ushist_q$us_pc, index_year=2014)
names(us_pc_index) <- "us_pc_index"
ushist_q <- merge(ushist_q, us_pc_index)
autoplot.zoo(ushist_q$us_pc_index)
```

![](050_create_ushist_files/figure-html/create_q-1.png)<!-- -->

```r
# select the series that contain adr or revpar and convert to real
# the way this works is that matches works on a regular expression
# I wrote a regular expression that is taking _adr_ or _revpar_
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
real_df <- data.frame(ushist_q) %>%
  select(matches("_adr$|_adr_sa|_revpar$|_revpar_sa")) %>% 
  mutate_each(funs(ind = ( . / us_pc_index)*100))
# adds on a time index to get it back to xts
temp <- data.frame(date=time(ushist_q)) 
real_df <- cbind(temp,real_df)
real <- read.zoo(real_df)
real <- xts(real)


# renames series 
tempnames <- names(real)
tempnames <- paste(tempnames,"rpc",sep="")
tempnames
```

```
##   [1] "anaheim_adrrpc"                "anaheim_adr_sarpc"            
##   [3] "anaheim_revparrpc"             "anaheim_revpar_sarpc"         
##   [5] "atlanta_adrrpc"                "atlanta_adr_sarpc"            
##   [7] "atlanta_revparrpc"             "atlanta_revpar_sarpc"         
##   [9] "boston_adrrpc"                 "boston_adr_sarpc"             
##  [11] "boston_revparrpc"              "boston_revpar_sarpc"          
##  [13] "chicago_adrrpc"                "chicago_adr_sarpc"            
##  [15] "chicago_revparrpc"             "chicago_revpar_sarpc"         
##  [17] "dallas_adrrpc"                 "dallas_adr_sarpc"             
##  [19] "dallas_revparrpc"              "dallas_revpar_sarpc"          
##  [21] "denver_adrrpc"                 "denver_adr_sarpc"             
##  [23] "denver_revparrpc"              "denver_revpar_sarpc"          
##  [25] "detroit_adrrpc"                "detroit_adr_sarpc"            
##  [27] "detroit_revparrpc"             "detroit_revpar_sarpc"         
##  [29] "ecous_adrrpc"                  "ecous_adr_sarpc"              
##  [31] "ecous_revparrpc"               "ecous_revpar_sarpc"           
##  [33] "houston_adrrpc"                "houston_adr_sarpc"            
##  [35] "houston_revparrpc"             "houston_revpar_sarpc"         
##  [37] "indus_adrrpc"                  "indus_adr_sarpc"              
##  [39] "indus_revparrpc"               "indus_revpar_sarpc"           
##  [41] "lalongbeach_adrrpc"            "lalongbeach_adr_sarpc"        
##  [43] "lalongbeach_revparrpc"         "lalongbeach_revpar_sarpc"     
##  [45] "luxus_adrrpc"                  "luxus_adr_sarpc"              
##  [47] "luxus_revparrpc"               "luxus_revpar_sarpc"           
##  [49] "miami_adrrpc"                  "miami_adr_sarpc"              
##  [51] "miami_revparrpc"               "miami_revpar_sarpc"           
##  [53] "midus_adrrpc"                  "midus_adr_sarpc"              
##  [55] "midus_revparrpc"               "midus_revpar_sarpc"           
##  [57] "minneapolis_adrrpc"            "minneapolis_adr_sarpc"        
##  [59] "minneapolis_revparrpc"         "minneapolis_revpar_sarpc"     
##  [61] "nashville_adrrpc"              "nashville_adr_sarpc"          
##  [63] "nashville_revparrpc"           "nashville_revpar_sarpc"       
##  [65] "neworleans_adrrpc"             "neworleans_adr_sarpc"         
##  [67] "neworleans_revparrpc"          "neworleans_revpar_sarpc"      
##  [69] "newyork_adrrpc"                "newyork_adr_sarpc"            
##  [71] "newyork_revparrpc"             "newyork_revpar_sarpc"         
##  [73] "norfolk_adrrpc"                "norfolk_adr_sarpc"            
##  [75] "norfolk_revparrpc"             "norfolk_revpar_sarpc"         
##  [77] "oahu_adrrpc"                   "oahu_adr_sarpc"               
##  [79] "oahu_revparrpc"                "oahu_revpar_sarpc"            
##  [81] "orlando_adrrpc"                "orlando_adr_sarpc"            
##  [83] "orlando_revparrpc"             "orlando_revpar_sarpc"         
##  [85] "philadelphia_adrrpc"           "philadelphia_adr_sarpc"       
##  [87] "philadelphia_revparrpc"        "philadelphia_revpar_sarpc"    
##  [89] "phoenix_adrrpc"                "phoenix_adr_sarpc"            
##  [91] "phoenix_revparrpc"             "phoenix_revpar_sarpc"         
##  [93] "sandiego_adrrpc"               "sandiego_adr_sarpc"           
##  [95] "sandiego_revparrpc"            "sandiego_revpar_sarpc"        
##  [97] "sanfrancisco_adrrpc"           "sanfrancisco_adr_sarpc"       
##  [99] "sanfrancisco_revparrpc"        "sanfrancisco_revpar_sarpc"    
## [101] "seattle_adrrpc"                "seattle_adr_sarpc"            
## [103] "seattle_revparrpc"             "seattle_revpar_sarpc"         
## [105] "stlouis_adrrpc"                "stlouis_adr_sarpc"            
## [107] "stlouis_revparrpc"             "stlouis_revpar_sarpc"         
## [109] "tampa_adrrpc"                  "tampa_adr_sarpc"              
## [111] "tampa_revparrpc"               "tampa_revpar_sarpc"           
## [113] "totus_adrrpc"                  "totus_adr_sarpc"              
## [115] "totus_revparrpc"               "totus_revpar_sarpc"           
## [117] "upmus_adrrpc"                  "upmus_adr_sarpc"              
## [119] "upmus_revparrpc"               "upmus_revpar_sarpc"           
## [121] "upsus_adrrpc"                  "upsus_adr_sarpc"              
## [123] "upsus_revparrpc"               "upsus_revpar_sarpc"           
## [125] "upuus_adrrpc"                  "upuus_adr_sarpc"              
## [127] "upuus_revparrpc"               "upuus_revpar_sarpc"           
## [129] "washingtondc_adrrpc"           "washingtondc_adr_sarpc"       
## [131] "washingtondc_revparrpc"        "washingtondc_revpar_sarpc"    
## [133] "anaheim_adr_indrpc"            "anaheim_adr_sa_indrpc"        
## [135] "anaheim_revpar_indrpc"         "anaheim_revpar_sa_indrpc"     
## [137] "atlanta_adr_indrpc"            "atlanta_adr_sa_indrpc"        
## [139] "atlanta_revpar_indrpc"         "atlanta_revpar_sa_indrpc"     
## [141] "boston_adr_indrpc"             "boston_adr_sa_indrpc"         
## [143] "boston_revpar_indrpc"          "boston_revpar_sa_indrpc"      
## [145] "chicago_adr_indrpc"            "chicago_adr_sa_indrpc"        
## [147] "chicago_revpar_indrpc"         "chicago_revpar_sa_indrpc"     
## [149] "dallas_adr_indrpc"             "dallas_adr_sa_indrpc"         
## [151] "dallas_revpar_indrpc"          "dallas_revpar_sa_indrpc"      
## [153] "denver_adr_indrpc"             "denver_adr_sa_indrpc"         
## [155] "denver_revpar_indrpc"          "denver_revpar_sa_indrpc"      
## [157] "detroit_adr_indrpc"            "detroit_adr_sa_indrpc"        
## [159] "detroit_revpar_indrpc"         "detroit_revpar_sa_indrpc"     
## [161] "ecous_adr_indrpc"              "ecous_adr_sa_indrpc"          
## [163] "ecous_revpar_indrpc"           "ecous_revpar_sa_indrpc"       
## [165] "houston_adr_indrpc"            "houston_adr_sa_indrpc"        
## [167] "houston_revpar_indrpc"         "houston_revpar_sa_indrpc"     
## [169] "indus_adr_indrpc"              "indus_adr_sa_indrpc"          
## [171] "indus_revpar_indrpc"           "indus_revpar_sa_indrpc"       
## [173] "lalongbeach_adr_indrpc"        "lalongbeach_adr_sa_indrpc"    
## [175] "lalongbeach_revpar_indrpc"     "lalongbeach_revpar_sa_indrpc" 
## [177] "luxus_adr_indrpc"              "luxus_adr_sa_indrpc"          
## [179] "luxus_revpar_indrpc"           "luxus_revpar_sa_indrpc"       
## [181] "miami_adr_indrpc"              "miami_adr_sa_indrpc"          
## [183] "miami_revpar_indrpc"           "miami_revpar_sa_indrpc"       
## [185] "midus_adr_indrpc"              "midus_adr_sa_indrpc"          
## [187] "midus_revpar_indrpc"           "midus_revpar_sa_indrpc"       
## [189] "minneapolis_adr_indrpc"        "minneapolis_adr_sa_indrpc"    
## [191] "minneapolis_revpar_indrpc"     "minneapolis_revpar_sa_indrpc" 
## [193] "nashville_adr_indrpc"          "nashville_adr_sa_indrpc"      
## [195] "nashville_revpar_indrpc"       "nashville_revpar_sa_indrpc"   
## [197] "neworleans_adr_indrpc"         "neworleans_adr_sa_indrpc"     
## [199] "neworleans_revpar_indrpc"      "neworleans_revpar_sa_indrpc"  
## [201] "newyork_adr_indrpc"            "newyork_adr_sa_indrpc"        
## [203] "newyork_revpar_indrpc"         "newyork_revpar_sa_indrpc"     
## [205] "norfolk_adr_indrpc"            "norfolk_adr_sa_indrpc"        
## [207] "norfolk_revpar_indrpc"         "norfolk_revpar_sa_indrpc"     
## [209] "oahu_adr_indrpc"               "oahu_adr_sa_indrpc"           
## [211] "oahu_revpar_indrpc"            "oahu_revpar_sa_indrpc"        
## [213] "orlando_adr_indrpc"            "orlando_adr_sa_indrpc"        
## [215] "orlando_revpar_indrpc"         "orlando_revpar_sa_indrpc"     
## [217] "philadelphia_adr_indrpc"       "philadelphia_adr_sa_indrpc"   
## [219] "philadelphia_revpar_indrpc"    "philadelphia_revpar_sa_indrpc"
## [221] "phoenix_adr_indrpc"            "phoenix_adr_sa_indrpc"        
## [223] "phoenix_revpar_indrpc"         "phoenix_revpar_sa_indrpc"     
## [225] "sandiego_adr_indrpc"           "sandiego_adr_sa_indrpc"       
## [227] "sandiego_revpar_indrpc"        "sandiego_revpar_sa_indrpc"    
## [229] "sanfrancisco_adr_indrpc"       "sanfrancisco_adr_sa_indrpc"   
## [231] "sanfrancisco_revpar_indrpc"    "sanfrancisco_revpar_sa_indrpc"
## [233] "seattle_adr_indrpc"            "seattle_adr_sa_indrpc"        
## [235] "seattle_revpar_indrpc"         "seattle_revpar_sa_indrpc"     
## [237] "stlouis_adr_indrpc"            "stlouis_adr_sa_indrpc"        
## [239] "stlouis_revpar_indrpc"         "stlouis_revpar_sa_indrpc"     
## [241] "tampa_adr_indrpc"              "tampa_adr_sa_indrpc"          
## [243] "tampa_revpar_indrpc"           "tampa_revpar_sa_indrpc"       
## [245] "totus_adr_indrpc"              "totus_adr_sa_indrpc"          
## [247] "totus_revpar_indrpc"           "totus_revpar_sa_indrpc"       
## [249] "upmus_adr_indrpc"              "upmus_adr_sa_indrpc"          
## [251] "upmus_revpar_indrpc"           "upmus_revpar_sa_indrpc"       
## [253] "upsus_adr_indrpc"              "upsus_adr_sa_indrpc"          
## [255] "upsus_revpar_indrpc"           "upsus_revpar_sa_indrpc"       
## [257] "upuus_adr_indrpc"              "upuus_adr_sa_indrpc"          
## [259] "upuus_revpar_indrpc"           "upuus_revpar_sa_indrpc"       
## [261] "washingtondc_adr_indrpc"       "washingtondc_adr_sa_indrpc"   
## [263] "washingtondc_revpar_indrpc"    "washingtondc_revpar_sa_indrpc"
```

```r
names(real) <- tempnames
rm(tempnames)

autoplot.zoo(window(real$luxus_adr_sarpc, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/create_q-2.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$luxus_adr_sa, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/create_q-3.png)<!-- -->

```r
# merges onto ushist_q
ushist_q <- merge(ushist_q, real)
autoplot.zoo(window(ushist_q$ecous_adr_sarpc, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/create_q-4.png)<!-- -->



```r
# merges onto ushist_q
ushist_q <- merge(ushist_q, out_str_ihg_mex_q,out_str_ihg_can_q)
autoplot.zoo(window(ushist_q$totcan_adr_sa, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_ihg_mex_can-1.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$totcan_demd_sa, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_ihg_mex_can-2.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$upmmex_revpar_sa, start="2000-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_ihg_mex_can-3.png)<!-- -->

Adds open close data

As background:
supd is average daily room nights during period
so for monthly data that's the measure of number of rooms
during the month. That's essentially the supply at the start of the month.

sups is going to be start of period supply in number of rooms. 
Calculate sups for quarterly data by taking supd of the first month of the quarter.

supe is the end of the quarter, so it should be set equal to the start of
supply from the next quarter


```r
# process is to create a quarterly object with open close and start/end of 
# period supply, and then merge it onto the quarterly object we're building

# just select the series we want
temp_opcl <- data.frame(date=time(out_opcl_q), out_opcl_q) %>%
  select(date, 
         totus_oprms_sa, 
         totus_oprms_sf, 
         totus_oprms, 
         totus_clrms) %>%
  read.zoo %>%
  as.xts
head(temp_opcl)
```

```
##            totus_oprms_sa totus_oprms_sf totus_oprms totus_clrms
## 1987-01-01       45764.39      0.8020209       36704         458
## 1987-04-01       39234.07      1.5442702       60588         141
## 1987-07-01       36770.22      0.8719012       32060           0
## 1987-10-01       32652.59      0.8011309       26159         350
## 1988-01-01       31393.39      0.8503701       26696         165
## 1988-04-01       35798.79      1.4698263       52618         991
```

```r
# setting up end of period and start of period supply quarterly

# use monthly supply to calculate start of quarter supply
# this approach is based on the help for aggregate.zoo 
# function which returns corresponding first "Date" of quarter
first.of.quarter <- function(tt) as.Date(as.yearqtr(tt))
sup_qtr <- aggregate(out_str_us_m$totus_supd, first.of.quarter, first, regular=TRUE) %>%
  xts()

# had to mannually add back the column names, not sure what happened
colnames(sup_qtr) <- c("totus_sups")

# create supe as lead of sups
# However, evidently dplyr was getting in the way of my ability to use the lag
# function to calculate a lead
# I found this discussion on github
# http://stackoverflow.com/questions/30466740/changing-behaviour-of-statslag-when-loading-dplyr-package
# my solution from that discussion was the stats::: approach, which I think is telling
# r to use the lag function from stats. for some reason it wouldn't work to do 
# xts:::lag
sup_qtr$totus_supe <- stats:::lag(sup_qtr$totus_sups, k=-1)

# as a check
head(out_str_us_m$totus_supd) #monthly
```

```
##            totus_supd
## 1987-01-01   2.866010
## 1987-02-01   2.876010
## 1987-03-01   2.894698
## 1987-04-01   2.922534
## 1987-05-01   2.969415
## 1987-06-01   3.012873
```

```r
head(sup_qtr$totus_sups) # based on start of quarter
```

```
##            totus_sups
## 1987-01-01   2.866010
## 1987-04-01   2.922534
## 1987-07-01   3.025464
## 1987-10-01   3.039061
## 1988-01-01   3.016977
## 1988-04-01   3.066167
```

```r
head(sup_qtr$totus_supe) # based on start of quarter
```

```
##            totus_supe
## 1987-01-01   2.922534
## 1987-04-01   3.025464
## 1987-07-01   3.039061
## 1987-10-01   3.016977
## 1988-01-01   3.066167
## 1988-04-01   3.160018
```

```r
# combine with ushist_q did in two steps just so
# I had a way to look at temp_opcl if I wanted to
temp_opcl <- merge(temp_opcl, sup_qtr)
ushist_q <- merge(ushist_q, temp_opcl)

# calculate the schange and schanger
ushist_q <- data.frame(date=time(ushist_q), ushist_q) %>%
  mutate(totus_schange = 
           totus_supe - totus_sups - totus_oprms /1000000 + totus_clrms/1000000,
         totus_schanger = totus_schange / totus_sups) %>%
  read.zoo %>%
  as.xts

# looking at data
autoplot.zoo(window(ushist_q$totus_oprms, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-1.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$totus_clrms, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-2.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$totus_schange, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-3.png)<!-- -->

```r
autoplot.zoo(window(ushist_q$totus_schanger, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-4.png)<!-- -->

```r
# looking at it as a ts
tempa <- na.exclude(ushist_q$totus_schange)*1000000
tempa_ts <<- ts(as.numeric(tempa), start=c(1987, 1), frequency=4)
plot(tempa_ts)
```

![](050_create_ushist_files/figure-html/add_opencl-5.png)<!-- -->

```r
head(tempa_ts)
```

```
## [1]  20278  42483 -18463 -47893  22659  42224
```

```r
monthplot(tempa_ts)
```

![](050_create_ushist_files/figure-html/add_opencl-6.png)<!-- -->

```r
# looking at schanger
tempa <- na.exclude(ushist_q$totus_schanger)
tempa_ts <<- ts(as.numeric(tempa), start=c(1987, 1), frequency=4)
#plot(tempa_ts)
head(tempa_ts)
```

```
## [1]  0.007075342  0.014536358 -0.006102535 -0.015759144  0.007510498
## [6]  0.013770939
```

```r
monthplot(tempa_ts)
```

![](050_create_ushist_files/figure-html/add_opencl-7.png)<!-- -->

```r
# if I adjust as seas, it works, but my function didn't
# I think the issue is that my function requires a transform.function ="log"
# which I don't think works with negative values
# so my temporary solution is to not use my fuction and just use seas directly
# generally follow the structure of my function

x <- ushist_q$totus_schanger
  #stores the name
  holdn <- names(x)
  print(holdn)
```

```
## [1] "totus_schanger"
```

```r
  # trims the NAs from the series
  x <- na.trim(x)
  # this series y is used in the output, just outputs the original series
  y <- x
y <- ts(as.numeric(y), start=c(1987, 1), frequency=4)
mp <- seas(y,
            # transform.function = "log",
             regression.aictest = NULL,
             regression.variables = c("const", "easter[8]"),
             identify.diff = c(0, 1),
             identify.sdiff = c(0, 1),
             forecast.maxlead = 30, # extends 30 quarters ahead
             x11.appendfcst = "yes", # appends the forecast of the seasonal factors
             dir = "output_data")
```

```
## All X-13ARIMA-SEATS output files have been copied to 'output_data'.
```

```r
  # grabs the seasonally adjusted series
  tempdata_sa <- series(mp, c("d11")) # seasonally adjusted series
  tempdata_sf <- series(mp, c("d16")) # seasonal factors
  tempdata_fct <- series(mp, "forecast.forecasts") # forecast of nonseasonally adjusted series
```

```
## All X-13ARIMA-SEATS output files have been copied to 'output_data'.
```

```r
  tempdata_irreg <- series(mp, c("d13")) # final irregular component
  
  # creates xts objects
  tempdata_sa <- as.xts(tempdata_sa)
  tempdata_sf <- as.xts(tempdata_sf)
  # in the following, we just want the forecast series, not the ci bounds
  # I had to do in two steps, I'm not sure why
  tempdata_fct <- as.xts(tempdata_fct) 
  tempdata_fct <- as.xts(tempdata_fct$forecast) 
  tempdata_irreg <- as.xts(tempdata_irreg)
  
  # names the objects
  names(tempdata_sa) <- paste(holdn,"_sa",sep="") 
  names(tempdata_sf) <- paste(holdn,"_sf",sep="") 
  names(tempdata_fct) <- paste(holdn,"_fct",sep="") 
  names(tempdata_irreg) <- paste(holdn,"_irreg",sep="") 

  # merges the adjusted series onto the existing xts object with the unadjusted
  # series
  out_sa <- merge(tempa, tempdata_sa, tempdata_sf, tempdata_fct, tempdata_irreg)

  # select a few that I want to add
  temp_schanger <- data.frame(date=time(out_sa), out_sa) %>%
  select(date, 
         totus_schanger_sa,
         totus_schanger_sf) %>%
  read.zoo %>%
  as.xts
  head(temp_schanger)
```

```
##            totus_schanger_sa totus_schanger_sf
## 1987-01-01     -0.0009173608       0.007992702
## 1987-04-01      0.0013048400       0.013231518
## 1987-07-01     -0.0010996620      -0.005002873
## 1987-10-01      0.0005022171      -0.016261361
## 1988-01-01     -0.0005391994       0.008049697
## 1988-04-01      0.0005910659       0.013179874
```

```r
autoplot.zoo(window(ushist_q$totus_schanger, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-8.png)<!-- -->

```r
autoplot.zoo(window(temp_schanger$totus_schanger_sa, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-9.png)<!-- -->

```r
# merge onto ushist_q
ushist_q <- merge(ushist_q, temp_schanger)

autoplot.zoo(window(ushist_q$totus_schange, start="1995-01-01", end="2015-10-01"))
```

![](050_create_ushist_files/figure-html/add_opencl-10.png)<!-- -->

Looking at what's in quarterly databank

```r
# which segments or markets are in the data frame, just for observation
# not used anywhere
a <- grep(pattern="_demt", colnames(ushist_q), value=TRUE)
a
```

```
##  [1] "anaheim_demt"      "atlanta_demt"      "boston_demt"      
##  [4] "chicago_demt"      "dallas_demt"       "denver_demt"      
##  [7] "detroit_demt"      "ecous_demt"        "houston_demt"     
## [10] "indus_demt"        "lalongbeach_demt"  "luxus_demt"       
## [13] "miami_demt"        "midus_demt"        "minneapolis_demt" 
## [16] "nashville_demt"    "neworleans_demt"   "newyork_demt"     
## [19] "norfolk_demt"      "oahu_demt"         "orlando_demt"     
## [22] "philadelphia_demt" "phoenix_demt"      "sandiego_demt"    
## [25] "sanfrancisco_demt" "seattle_demt"      "stlouis_demt"     
## [28] "tampa_demt"        "totus_demt"        "upmus_demt"       
## [31] "upsus_demt"        "upuus_demt"        "washingtondc_demt"
## [34] "upmmex_demt"       "upmmexusd_demt"    "totcan_demt"
```

```r
a <- gsub(pattern="_demt",replacement="",a)
a
```

```
##  [1] "anaheim"      "atlanta"      "boston"       "chicago"     
##  [5] "dallas"       "denver"       "detroit"      "ecous"       
##  [9] "houston"      "indus"        "lalongbeach"  "luxus"       
## [13] "miami"        "midus"        "minneapolis"  "nashville"   
## [17] "neworleans"   "newyork"      "norfolk"      "oahu"        
## [21] "orlando"      "philadelphia" "phoenix"      "sandiego"    
## [25] "sanfrancisco" "seattle"      "stlouis"      "tampa"       
## [29] "totus"        "upmus"        "upsus"        "upuus"       
## [33] "washingtondc" "upmmex"       "upmmexusd"    "totcan"
```

```r
b <- grep(pattern="totus_", colnames(ushist_q), value=TRUE)
b
```

```
##  [1] "totus_adr"              "totus_adr_sa"          
##  [3] "totus_adr_sf"           "totus_days"            
##  [5] "totus_demar_sa"         "totus_demd"            
##  [7] "totus_demd_sa"          "totus_demd_sf"         
##  [9] "totus_demt"             "totus_occ"             
## [11] "totus_occ_sa"           "totus_occ_sf"          
## [13] "totus_revpar"           "totus_revpar_sa"       
## [15] "totus_revpar_sf"        "totus_rmrevt"          
## [17] "totus_supd"             "totus_supd_sa"         
## [19] "totus_supd_sf"          "totus_supt"            
## [21] "totus_strdays"          "totus_adrrpc"          
## [23] "totus_adr_sarpc"        "totus_revparrpc"       
## [25] "totus_revpar_sarpc"     "totus_adr_indrpc"      
## [27] "totus_adr_sa_indrpc"    "totus_revpar_indrpc"   
## [29] "totus_revpar_sa_indrpc" "totus_oprms_sa"        
## [31] "totus_oprms_sf"         "totus_oprms"           
## [33] "totus_clrms"            "totus_sups"            
## [35] "totus_supe"             "totus_schange"         
## [37] "totus_schanger"         "totus_schanger_sa"     
## [39] "totus_schanger_sf"
```


Create a sum of top 25 metros

```r
top25list <- c("anaheim", "atlanta", "boston", "chicago", 
               "dallas", "denver", "detroit", "houston", 
               "lalongbeach",  "miami", "minneapolis",  "nashville",
               "neworleans", "newyork", "norfolk", "oahu", 
               "orlando", "philadelphia", "phoenix", "sandiego", 
               "sanfrancisco", "seattle", "stlouis", "tampa", 
               "washingtondc")

top25cols <- unique (grep(paste(top25list,collapse="|"), 
                        colnames(ushist_q), value=TRUE))

# follows the code for creating the annual databank, see comments in next code chunk
top25sum <- data.frame(ushist_q) %>%
  select(matches("_demt|_supt|_rmrevt")) %>%
  select(matches(paste(top25cols, collapse="|"))) %>%
  as.xts()

  # takes the summed data and spreads it into a tidy format with tidyr
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
top25sum <- data.frame(date=time(top25sum), top25sum)%>% 
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # in the following the ^ means anything not in the list
  # with the list being all characters and numbers
  # so it separates segvar into two colums using sep
  separate(segvar, c("seg", "variable"), sep = "[^[:alnum:]]+") %>%
  # keeps seg as a column and spreads variable into multiple columns containing
  # containing the values
  spread(variable,value) 

top25sum <- top25sum %>%
  # sets up in dplyr that it will summarize by quarters
  group_by(date) %>%
  # calculates top25us as the sum of the markets in the dataframe
  summarize(top25us_demt=sum(demt), top25us_supt=sum(supt), 
            top25us_rmrevt=sum(rmrevt)) %>%
  mutate(top25us_occ = top25us_demt / top25us_supt) %>%
  mutate(top25us_revpar = top25us_rmrevt / top25us_supt) %>%
  mutate(top25us_adr = top25us_rmrevt / top25us_demt) 

top25sum <- top25sum %>%
  # there's a bit of a bug in dplyr in that the data frame
  # can't be directly read by read.zoo, something about a
  # bad entry error that happens. So the short term solution
  # is to have the as.data.frame step. Here's the bug report
  # which will presumably be fixed at some point
  # https://github.com/hadley/dplyr/issues/686
  as.data.frame() %>%
  # added this step because it was previously coming through with a 
  #POSIXct format data that wasn't working well in the subsequent merge step
  mutate(date = as.Date(date)) %>%
  read.zoo() %>%
  xts()

ushist_q <- merge(ushist_q, top25sum)
```


Create annual databank

```r
# start with those that should be summed

# select series that should be converted to annual by summing
# I wrote a regular expression that is looking for certain text strings
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
suma <- data.frame(ushist_q) %>%
  select(matches("_demt|_supt|_rmrevt"), totus_oprms, totus_clrms, totus_schange) %>%
  as.xts()

# this function is one I defined, it converts all the columns in 
# an xts object to annual. Must be an xts object to start with
suma <- q_to_a_xts(suma, type="sum")

# takes the summed data and spreads it into a tidy format with
# tidyr and then calculates the occupancy and revpar series
# first needs to go from xts to dataframe
tb2 <- data.frame(date=time(suma), suma)%>% 
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # in the following the ^ means anything not in the list
  # with the list being all characters and numbers
  # so it separates segvar into two colums using sep
  separate(segvar, c("seg", "variable"), sep = "[^[:alnum:]]+") %>%
  # keeps seg as a column and spreads variable into multiple columns containing
  # containint the values
  spread(variable,value) %>%
  # adds new calculated column
  mutate(occ = demt / supt) %>%
  # adds another column
  mutate(revpar = rmrevt / supt) %>%
  mutate(adr = rmrevt / demt)

# takes it from a tidy format and melts it, and then creates the unique
# variable names and then reads into a zoo object spliting on the 
# second column
#a <- reshape2::melt(tb2, id=c("date","seg"), na.rm=FALSE)
a <- tb2 %>%
  gather(variable, value, -date, -seg)
a$variable <- paste(a$seg, "_", a$var, sep='')
a$seg <- NULL
ushist_a <- xts(read.zoo(a, split = 2))

# looking at a few graphs
autoplot.zoo(ushist_a$totus_schange)
```

```
## Warning: Removed 22 rows containing missing values (geom_path).
```

![](050_create_ushist_files/figure-html/create_a-1.png)<!-- -->

```r
autoplot.zoo(ushist_a$luxus_revpar)
```

```
## Warning: Removed 22 rows containing missing values (geom_path).
```

![](050_create_ushist_files/figure-html/create_a-2.png)<!-- -->

```r
autoplot.zoo(window(ushist_a$totus_occ, start=as.Date("1987-01-01"), end=as.Date("2015-10-01")))
```

![](050_create_ushist_files/figure-html/create_a-3.png)<!-- -->

Creating monthly historical databank

```r
# not that much that needs to be done
ushist_m <- out_str_us_m
ushist_m <- merge(ushist_m, out_str_ihg_mex_m, out_str_ihg_can_m)
```

Create monthly, annual and quarterly databank with just US, mexico and canada

```r
# this is to a historical databank with just US data, so the markets aren't in it

usihg_list <-   c("us_", "ecous", "indus", "luxus", "midus", "upmus", "upsus", "upuus", "totus", "upmmex", "totcan", "mex_", "can_")
# this accidentally also grabs the top25us series, but that's ok
# extracts anything in the series list

usihghist_q <- data.frame(ushist_q) %>%
  select(matches(paste(usihg_list,collapse="|"))) %>%
  as.xts()

usihghist_m <- data.frame(ushist_m) %>%
  select(matches(paste(usihg_list,collapse="|"))) %>%
  as.xts()

usihghist_a <- data.frame(ushist_a) %>%
  select(matches(paste(usihg_list,collapse="|"))) %>%
  as.xts()

# a <- usihghist_q %>%
#   data.frame(date=time(.), .) %>%
#   select(date, starts_with("upmmex"))
```

### Writing outputs

