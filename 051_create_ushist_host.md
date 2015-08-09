---
title: "create_ushist"
author: "Tourism Economics"
date: "Thursday, October 16, 2014"
output: html_document
---

This is basically the same as create_ushist. To make this, I changed it to import the host Rdata files. 
Then it runs through wich much the same naming as ushist_q for example. I deleted the parts related to 
opens and closes. And removed stuff about IHG canada and mexico. And changed from creating a top25 to 
a sum of the selected markets. I had to rework the top25 piece that was suming the top 25 markets because
in the host data there is multiple chain scales for the metros, and it was suming them. So I changed it 
to be selected markets, and then grouped by date and seg. So that works, and I made other changes to handle
the fact there is info about the separate segments that needs to become part of the series names. but it doesn't
result in seasonally adjusted data, so I'm not sure if I was doing this in the right place or not, maybe
I should have been using the separate file to compile top25 anyway. 


Setup

```r
#read_chunk('~/Project/R projects/lodfor/scripts/functions.R')
source('~/Project/R projects/lodfor/scripts/functions.R')
```


Creates a us historical databank. Combines the STR data with selected macro data and calculates a few series

```r
# require("tidyr")
# require("zoo")
# require("xts")
# require("ggplot2")
# require("tframePlus")
# require("seasonal")
# Sys.setenv(X13_PATH = "C:/Aran Installed/x13as")
# checkX13()

fpath <- c("~/Project/R projects/lodfor/") 
#macro data
  load(paste(fpath,"output_data/oe_usmac_q.Rdata", sep=""))
# str data
  load(paste(fpath,"output_data/out_str_us_host_q.Rdata", sep="")) 
  load(paste(fpath,"output_data/out_str_us_host_m.Rdata", sep=""))
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
         mex_gdp,
         mex_cpi
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
## 1980-01-01 6.30000 1644.10 42.398 1147.47    9238.63   59.375 79.0333
## 1980-04-01 7.33333 1652.90 43.435 1130.80    9582.46   51.750 81.7000
## 1980-07-01 7.66667 1661.20 44.449 1144.56    9985.13   53.650 83.2333
## 1980-10-01 7.40000 1669.35 45.547 1167.01   10326.60   58.775 85.5667
## 1981-01-01 7.43333 1677.95 46.675 1163.91   10522.40   61.100 87.9333
## 1981-04-01 7.40000 1687.60 47.454 1163.67   10786.30   60.200 89.7667
##            us_usrecq can_gdp can_cpi mex_gdp  mex_cpi
## 1980-01-01         0  191254 42.2796 1491.85 0.101089
## 1980-04-01         1  190837 43.4352 1501.59 0.106925
## 1980-07-01         1  190770 44.6358 1534.00 0.113918
## 1980-10-01         0  192913 45.9055 1578.43 0.119657
## 1981-01-01         0  197732 47.4281 1613.67 0.129351
## 1981-04-01         0  199870 48.9277 1655.48 0.137261
```

```r
# merges dataframes. the all.=TRUE piece ensures all the rows
# in the first dataframe are included
ushist_q <- merge(temp, out_str_us_host_q, all=TRUE) 

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
autoplot(ushist_q$us_pc_index)
```

![plot of chunk create_q](figure/create_q-1.png) 

```r
# select the series that contain adr or revpar and convert to real
# the way this works is that matches works on a regular expression
# I wrote a regular expression that is taking _adr_ or _revpar_
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
real_df <- data.frame(ushist_q) %>%
  select(matches("_adr$|_adr_sa|_revpar$|_revpar_sa")) %>%
  # creates a date column which is useful in a bit because dplyr drops rownames
    mutate(date = rownames(.)) %>%
  # moves date to first column
  select(date, everything())

# to remove columns that are all NA
real_df <- real_df[,colSums(is.na(real_df))<nrow(real_df)]

real_df <- real_df %>%
  select(1:100) %>%
  # dplyr makes no guarantee that it will keep row names
  # if you only have one function in mutate_each, it will keep the column names
  # this also specifies that it should skip the date column
  mutate_each(funs(ind = ( . / us_pc_index)*100), -date) %>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"rpc")))

# back to xts
real <- read.zoo(real_df) %>%
  xts()

autoplot(window(real$upachi_adr_sarpc, start="2000-01-01", end="2014-10-01"))
```

```
## Error in hasTsp(x): attempt to set an attribute on NULL
```

```r
autoplot(window(ushist_q$upachi_revpar_sa, start="2000-01-01", end="2014-10-01"))
```

![plot of chunk create_q](figure/create_q-2.png) 

```r
autoplot(window(ushist_q$upachi_revpar, start="2000-01-01", end="2014-10-01"))
```

![plot of chunk create_q](figure/create_q-3.png) 

```r
autoplot(window(ushist_q$luxus_adr_sa, start="2000-01-01", end="2014-10-01"))
```

```
## Error in seq.default(from = best$lmin, to = best$lmax, by = best$lstep): 'from' must be of length 1
```

```r
# merges onto ushist_q
ushist_q <- merge(ushist_q, real)
autoplot(window(ushist_q$upaus_adr, start="2000-01-01", end="2014-10-01"))
```

![plot of chunk create_q](figure/create_q-4.png) 

```r
autoplot(window(ushist_q$upaus_adr_sa, start="2000-01-01", end="2014-10-01"))
```

![plot of chunk create_q](figure/create_q-5.png) 

```r
autoplot(window(ushist_q$upaus_adr_sarpc, start="2000-01-01", end="2014-10-01"))
```

```
## Error in hasTsp(x): attempt to set an attribute on NULL
```

Looking at what's in quarterly databank

```r
# which segments or markets are in the data frame, just for observation
# not used anywhere
a <- grep(pattern="_demt", colnames(ushist_q), value=TRUE)
a
```

```
##   [1] "luxast_demt" "luxatl_demt" "luxbos_demt" "luxchi_demt" "luxden_demt"
##   [6] "luxdll_demt" "luxhou_demt" "luxlos_demt" "luxmau_demt" "luxmia_demt"
##  [11] "luxmou_demt" "luxmxc_demt" "luxnol_demt" "luxnyc_demt" "luxoah_demt"
##  [16] "luxorg_demt" "luxorl_demt" "luxphl_demt" "luxpho_demt" "luxsea_demt"
##  [21] "luxsfj_demt" "luxsna_demt" "luxsnd_demt" "luxsnf_demt" "luxsnj_demt"
##  [26] "luxtor_demt" "luxus_demt"  "luxwas_demt" "totast_demt" "totatl_demt"
##  [31] "totbos_demt" "totcal_demt" "totchi_demt" "totcho_demt" "totchr_demt"
##  [36] "totden_demt" "totdll_demt" "tothou_demt" "totind_demt" "totlos_demt"
##  [41] "totmau_demt" "totmia_demt" "totmmp_demt" "totmnn_demt" "totmou_demt"
##  [46] "totmxc_demt" "totnol_demt" "totnsh_demt" "totnyc_demt" "totoah_demt"
##  [51] "totorg_demt" "totorl_demt" "totphl_demt" "totpho_demt" "totprt_demt"
##  [56] "totrlg_demt" "totsea_demt" "totsfj_demt" "totslc_demt" "totsna_demt"
##  [61] "totsnd_demt" "totsnf_demt" "totsnj_demt" "tottor_demt" "tottpa_demt"
##  [66] "totus_demt"  "totvnc_demt" "totwas_demt" "upaast_demt" "upaatl_demt"
##  [71] "upabos_demt" "upacal_demt" "upachi_demt" "upacho_demt" "upachr_demt"
##  [76] "upaden_demt" "upadll_demt" "upahou_demt" "upaind_demt" "upalos_demt"
##  [81] "upamau_demt" "upamia_demt" "upammp_demt" "upamnn_demt" "upamou_demt"
##  [86] "upamxc_demt" "upanol_demt" "upansh_demt" "upanyc_demt" "upaoah_demt"
##  [91] "upaorg_demt" "upaorl_demt" "upaphl_demt" "upapho_demt" "upaprt_demt"
##  [96] "uparlg_demt" "upasea_demt" "upasfj_demt" "upaslc_demt" "upasna_demt"
## [101] "upasnd_demt" "upasnf_demt" "upasnj_demt" "upator_demt" "upatpa_demt"
## [106] "upaus_demt"  "upavnc_demt" "upawas_demt" "upsast_demt" "upsatl_demt"
## [111] "upsbos_demt" "upschi_demt" "upscho_demt" "upschr_demt" "upsden_demt"
## [116] "upsdll_demt" "upshou_demt" "upsind_demt" "upslos_demt" "upsmau_demt"
## [121] "upsmia_demt" "upsmmp_demt" "upsmnn_demt" "upsmou_demt" "upsnol_demt"
## [126] "upsnsh_demt" "upsnyc_demt" "upsoah_demt" "upsorg_demt" "upsorl_demt"
## [131] "upsphl_demt" "upspho_demt" "upsprt_demt" "upsrlg_demt" "upssea_demt"
## [136] "upssfj_demt" "upsslc_demt" "upssna_demt" "upssnd_demt" "upssnf_demt"
## [141] "upssnj_demt" "upstpa_demt" "upsus_demt"  "upswas_demt" "upuast_demt"
## [146] "upuatl_demt" "upubos_demt" "upucal_demt" "upuchi_demt" "upucho_demt"
## [151] "upuchr_demt" "upuden_demt" "upudll_demt" "upuhou_demt" "upuind_demt"
## [156] "upulos_demt" "upumau_demt" "upumia_demt" "upummp_demt" "upumnn_demt"
## [161] "upumou_demt" "upumxc_demt" "upunol_demt" "upunsh_demt" "upunyc_demt"
## [166] "upuoah_demt" "upuorg_demt" "upuorl_demt" "upuphl_demt" "upupho_demt"
## [171] "upuprt_demt" "upurlg_demt" "upusea_demt" "upusfj_demt" "upuslc_demt"
## [176] "upusna_demt" "upusnd_demt" "upusnf_demt" "upusnj_demt" "uputor_demt"
## [181] "uputpa_demt" "upuus_demt"  "upuvnc_demt" "upuwas_demt"
```

```r
a <- gsub(pattern="_demt",replacement="",a)
a
```

```
##   [1] "luxast" "luxatl" "luxbos" "luxchi" "luxden" "luxdll" "luxhou"
##   [8] "luxlos" "luxmau" "luxmia" "luxmou" "luxmxc" "luxnol" "luxnyc"
##  [15] "luxoah" "luxorg" "luxorl" "luxphl" "luxpho" "luxsea" "luxsfj"
##  [22] "luxsna" "luxsnd" "luxsnf" "luxsnj" "luxtor" "luxus"  "luxwas"
##  [29] "totast" "totatl" "totbos" "totcal" "totchi" "totcho" "totchr"
##  [36] "totden" "totdll" "tothou" "totind" "totlos" "totmau" "totmia"
##  [43] "totmmp" "totmnn" "totmou" "totmxc" "totnol" "totnsh" "totnyc"
##  [50] "totoah" "totorg" "totorl" "totphl" "totpho" "totprt" "totrlg"
##  [57] "totsea" "totsfj" "totslc" "totsna" "totsnd" "totsnf" "totsnj"
##  [64] "tottor" "tottpa" "totus"  "totvnc" "totwas" "upaast" "upaatl"
##  [71] "upabos" "upacal" "upachi" "upacho" "upachr" "upaden" "upadll"
##  [78] "upahou" "upaind" "upalos" "upamau" "upamia" "upammp" "upamnn"
##  [85] "upamou" "upamxc" "upanol" "upansh" "upanyc" "upaoah" "upaorg"
##  [92] "upaorl" "upaphl" "upapho" "upaprt" "uparlg" "upasea" "upasfj"
##  [99] "upaslc" "upasna" "upasnd" "upasnf" "upasnj" "upator" "upatpa"
## [106] "upaus"  "upavnc" "upawas" "upsast" "upsatl" "upsbos" "upschi"
## [113] "upscho" "upschr" "upsden" "upsdll" "upshou" "upsind" "upslos"
## [120] "upsmau" "upsmia" "upsmmp" "upsmnn" "upsmou" "upsnol" "upsnsh"
## [127] "upsnyc" "upsoah" "upsorg" "upsorl" "upsphl" "upspho" "upsprt"
## [134] "upsrlg" "upssea" "upssfj" "upsslc" "upssna" "upssnd" "upssnf"
## [141] "upssnj" "upstpa" "upsus"  "upswas" "upuast" "upuatl" "upubos"
## [148] "upucal" "upuchi" "upucho" "upuchr" "upuden" "upudll" "upuhou"
## [155] "upuind" "upulos" "upumau" "upumia" "upummp" "upumnn" "upumou"
## [162] "upumxc" "upunol" "upunsh" "upunyc" "upuoah" "upuorg" "upuorl"
## [169] "upuphl" "upupho" "upuprt" "upurlg" "upusea" "upusfj" "upuslc"
## [176] "upusna" "upusnd" "upusnf" "upusnj" "uputor" "uputpa" "upuus" 
## [183] "upuvnc" "upuwas"
```

```r
b <- grep(pattern="totus_", colnames(ushist_q), value=TRUE)
b
```

```
##  [1] "totus_adr"       "totus_adr_sa"    "totus_adr_sf"   
##  [4] "totus_days"      "totus_demar_sa"  "totus_demd"     
##  [7] "totus_demd_sa"   "totus_demd_sf"   "totus_demt"     
## [10] "totus_occ"       "totus_occ_sa"    "totus_occ_sf"   
## [13] "totus_revpar"    "totus_revpar_sa" "totus_revpar_sf"
## [16] "totus_rmrevt"    "totus_supd"      "totus_supd_sa"  
## [19] "totus_supd_sf"   "totus_supt"
```

Create a sum of top 25 metros

```r
# 
# I commetted this out. my thought is that it may be better to set up a compile_top25 type file to do this
# that can handle seasonally adjusting and putting into real terms

# selectm_list <- c("atl", "bos", "chi", "den", "hou", "los", "mia", "mou",
#                      "nol", "nyc", "org", "orl", "phl", "pho", "sea", "snd",
#                      "snf",  "was")
# 
# selectm_cols <- unique (grep(paste(selectm_list,collapse="|"), 
#                         colnames(ushist_q), value=TRUE))
# 
# # follows the code for creating the annual databank, see comments in next code chunk
# selectm_sum <- data.frame(ushist_q) %>%
#   select(matches("_demt|_supt|_rmrevt")) %>%
#   select(matches(paste(selectm_cols, collapse="|"))) %>%
#   as.xts()
# 
#   # takes the summed data and spreads it into a tidy format with tidyr
#   # creates column called segvar that contains the column names, and one next to 
#   # it with the values, dropping the time column
# selectm_sum <- data.frame(date=time(selectm_sum), selectm_sum)%>% 
#   # creates column called segvar that contains the column names, and one next to 
#   # it with the values, dropping the time column
#   gather(segvar, value, -date, na.rm = FALSE) %>%
#   # in the following the ^ means anything not in the list
#   # with the list being all characters and numbers
#   # so it separates segvar into two colums using sep
#   separate(segvar, c("seggeo", "variable"), sep = "[^[:alnum:]]+") %>%
#   # keeps seg as a column and spreads variable into multiple columns containing
#   # containing the values
#   mutate(seg = substr(seggeo, 1, 3)) %>%
#   mutate(geo = substr(seggeo, 4, 6)) %>%
#   select(-seggeo) %>%
#   spread(variable,value) 
# 
# selectm_sum <- selectm_sum %>%
#   # sets up in dplyr that it will summarize by quarters
#   group_by(date, seg) %>%
#   # calculates top25us as the sum of the markets in the dataframe
#   summarize(slm_demt=sum(demt), slm_supt=sum(supt), 
#             slm_rmrevt=sum(rmrevt)) %>%
#   mutate(slm_occ = slm_demt / slm_supt) %>%
#   mutate(slm_revpar = slm_rmrevt / slm_supt) %>%
#   mutate(slm_adr = slm_rmrevt / slm_demt) %>%
#   # added this for host situation
#   gather(segvar, value, -date, -seg, na.rm = FALSE) %>%
#   mutate(segvar = paste(seg, segvar, sep="")) %>%
#   select(-seg) %>%
#   spread(segvar,value) 
# 
# selectm_sum <- selectm_sum %>%
#   # there's a bit of a bug in dplyr in that the data frame
#   # can't be directly read by read.zoo, something about a
#   # bad entry error that happens. So the short term solution
#   # is to have the as.data.frame step. Here's the bug report
#   # which will presumably be fixed at some point
#   # https://github.com/hadley/dplyr/issues/686
#   as.data.frame() %>%
#   read.zoo() %>%
#   xts()
# 
# ushist_q <- merge(ushist_q, selectm_sum)
```


Create annual databank

```r
# start with those that should be summed

# select series that should be converted to annual by summing
# I wrote a regular expression that is looking for certain text strings
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
suma <- data.frame(ushist_q) %>%
  select(matches("_demt|_supt|_rmrevt")) %>%
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

a <- tb2$segvar
b <- unique(a)
b
```

```
## NULL
```

```r
# takes it from a tidy format and melts it, and then creates the unique
# variable names and then reads into a zoo object spliting on the 
# second column
a <- melt(tb2, id=c("date","seg"), na.rm=FALSE)
a$variable <- paste(a$seg, "_", a$var, sep='')
a$seg <- NULL
ushist_a <- xts(read.zoo(a, split = 2))

# looking at a few graphs
autoplot(ushist_a$luxus_revpar)
```

```
## Warning: Removed 22 rows containing missing values (geom_path).
```

![plot of chunk create_a](figure/create_a-1.png) 

```r
autoplot(window(ushist_a$totus_occ, start=as.Date("1987-01-01"), end=as.Date("2014-01-01")))
```

![plot of chunk create_a](figure/create_a-2.png) 

Creating monthly historical databank

```r
# not that much that needs to be done
ushist_m <- out_str_us_host_m
#ushist_m <- merge(ushist_m)
```






Writing outputs

