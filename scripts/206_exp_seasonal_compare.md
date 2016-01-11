# Seasonal adjustment comparison
Tourism Economics  
January 9, 2016  










### Set up data to run using: totus_demd

  











## Set up Veteran's Day weekend
vet_wkend is "1" if Veteran's Day falls on a weekend

date         wday     satsun  month       day   vet   vet_wkend
-----------  ------  -------  ---------  ----  ----  ----------
2018-11-11   Sun           1  November     11     1           1
2019-11-11   Mon           0  November     11     1           0
2020-11-11   Wed           0  November     11     1           0
2021-11-11   Thurs         0  November     11     1           0
2022-11-11   Fri           0  November     11     1           0
2023-11-11   Sat           1  November     11     1           1
2024-11-11   Mon           0  November     11     1           0
2025-11-11   Tues          0  November     11     1           0
2026-11-11   Wed           0  November     11     1           0
2027-11-11   Thurs         0  November     11     1           0
2028-11-11   Sat           1  November     11     1           1
2029-11-11   Sun           1  November     11     1           1

## Set up Christmas weekend
chr_wkend is "1" if Christmas Day falls on a weekend

date         wday     satsun  month       day   chr   chr_wkend
-----------  ------  -------  ---------  ----  ----  ----------
2018-12-25   Tues          0  December     25     1           0
2019-12-25   Wed           0  December     25     1           0
2020-12-25   Fri           0  December     25     1           0
2021-12-25   Sat           1  December     25     1           1
2022-12-25   Sun           1  December     25     1           1
2023-12-25   Mon           0  December     25     1           0
2024-12-25   Wed           0  December     25     1           0
2025-12-25   Thurs         0  December     25     1           0
2026-12-25   Fri           0  December     25     1           0
2027-12-25   Sat           1  December     25     1           1
2028-12-25   Mon           0  December     25     1           0
2029-12-25   Tues          0  December     25     1           0

## Set up July 4th weekend
jlf_wkend is "1" if Independence Day falls on a weekend

date         wday     satsun  month    day   jlf   jlf_wkend
-----------  ------  -------  ------  ----  ----  ----------
2018-07-04   Wed           0  July       4     1           0
2019-07-04   Thurs         0  July       4     1           0
2020-07-04   Sat           1  July       4     1           1
2021-07-04   Sun           1  July       4     1           1
2022-07-04   Mon           0  July       4     1           0
2023-07-04   Tues          0  July       4     1           0
2024-07-04   Thurs         0  July       4     1           0
2025-07-04   Fri           0  July       4     1           0
2026-07-04   Sat           1  July       4     1           1
2027-07-04   Sun           1  July       4     1           1
2028-07-04   Tues          0  July       4     1           0
2029-07-04   Wed           0  July       4     1           0



## Set up three models
m1: defaults  
  
m2: built-in regressors:  
  - "tdnolpyear" (trading days without assuming leap year)   
  - "easter[1]" (Easter, start the effect one day before)  
  - "labor[3]" (Labor Day, start the effect three days before)  
  
m3: same built-in regressors, plus: 
- thank[3]: built-in regressor, number of days in period starting three days before Thanksgiving  
- ls2001.Sep: Assume Sep 11, 2001 is an outlier  
- xreg1: (vet1) Veteran's Day on a weekend  
- xreg2: (chr1) Christmas Day on a weekend  
- xreg3: (jlf1) Independence Day on a weekend  
  

### Original and adjusted series from the models

date             oa1      oa2      oa3   sa1_sf   sa2_sf   sa3_sf      sa1      sa2      sa3
-----------  -------  -------  -------  -------  -------  -------  -------  -------  -------
2014-10-01    3.3616   3.3616   3.3616   1.0498   1.0482   1.0462   3.2023   3.2071   3.2131
2014-11-01    2.8817   2.8817   2.8817   0.8986   0.8990   0.8987   3.2070   3.2054   3.2066
2014-12-01    2.5759   2.5759   2.5759   0.7951   0.7969   0.7967   3.2399   3.2322   3.2332
2015-01-01    2.6576   2.6576   2.6576   0.8211   0.8220   0.8215   3.2365   3.2331   3.2351
2015-02-01    3.0474   3.0474   3.0474   0.9404   0.9425   0.9410   3.2406   3.2334   3.2386
2015-03-01    3.2823   3.2823   3.2823   1.0138   1.0144   1.0148   3.2377   3.2358   3.2344
2015-04-01    3.3039   3.3039   3.3039   1.0179   1.0185   1.0192   3.2458   3.2438   3.2417
2015-05-01    3.3637   3.3637   3.3637   1.0362   1.0364   1.0381   3.2463   3.2456   3.2402
2015-06-01    3.6511   3.6511   3.6511   1.1230   1.1245   1.1274   3.2511   3.2469   3.2385
2015-07-01    3.7683   3.7683   3.7683   1.1558   1.1553   1.1601   3.2603   3.2616   3.2482
2015-08-01    3.5391   3.5391   3.5391   1.0906   1.0867   1.0884   3.2450   3.2567   3.2516
2015-09-01    3.4047   3.4047   3.4047   1.0362   1.0415   1.0424   3.2858   3.2691   3.2662

### m1
Default

```
## 
## Call:
## seas(x = temp_ser_ts, forecast.maxlead = 30, seats.appendfcst = "yes")
## 
## Coefficients:
##                     Estimate Std. Error z value Pr(>|z|)    
## Mon               -3.929e-03  1.369e-03  -2.870 0.004108 ** 
## Tue                2.241e-03  1.379e-03   1.625 0.104266    
## Wed               -7.335e-05  1.370e-03  -0.054 0.957309    
## Thu               -7.482e-04  1.365e-03  -0.548 0.583536    
## Fri                4.930e-03  1.366e-03   3.610 0.000306 ***
## Sat                3.533e-03  1.373e-03   2.574 0.010051 *  
## Easter[1]         -8.534e-03  2.824e-03  -3.022 0.002513 ** 
## LS2001.Sep        -9.349e-02  1.238e-02  -7.554 4.22e-14 ***
## AR-Nonseasonal-01 -4.168e-01  4.939e-02  -8.439  < 2e-16 ***
## AR-Seasonal-12     2.160e-01  7.732e-02   2.794 0.005202 ** 
## MA-Seasonal-12     7.568e-01  5.202e-02  14.549  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## SEATS adj.  ARIMA: (1 1 0)(1 1 1)  Obs.: 345  Transform: log
## AICc: -1204, BIC: -1160  QS (no seasonality in final):    0  
## Box-Ljung (no autocorr.): 31.49   Shapiro (normality): 0.9894 *
```

### m2
Built-in regressors

```
## 
## Call:
## seas(x = temp_ser_ts, regression.variables = c("tdnolpyear", 
##     "easter[1]", "labor[3]", "ls2001.Sep"), forecast.maxlead = 30, 
##     seats.appendfcst = "yes")
## 
## Coefficients:
##                     Estimate Std. Error z value Pr(>|z|)    
## Labor[3]           0.0183694  0.0028866   6.364 1.97e-10 ***
## LS2001.Sep        -0.0940476  0.0096871  -9.709  < 2e-16 ***
## Mon               -0.0018562  0.0010188  -1.822 0.068468 .  
## Tue                0.0013889  0.0009989   1.391 0.164376    
## Wed                0.0003909  0.0009977   0.392 0.695191    
## Thu               -0.0005050  0.0009875  -0.511 0.609050    
## Fri                0.0040099  0.0009965   4.024 5.72e-05 ***
## Sat                0.0032067  0.0009914   3.235 0.001218 ** 
## Easter[1]         -0.0084798  0.0020342  -4.169 3.06e-05 ***
## AO1999.Dec        -0.0338847  0.0082368  -4.114 3.89e-05 ***
## LS2001.Nov         0.0424068  0.0096799   4.381 1.18e-05 ***
## AR-Nonseasonal-01 -0.3305550  0.0514049  -6.430 1.27e-10 ***
## AR-Seasonal-12     0.3168761  0.0861212   3.679 0.000234 ***
## MA-Seasonal-12     0.7356117  0.0618218  11.899  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## SEATS adj.  ARIMA: (1 1 0)(1 1 1)  Obs.: 345  Transform: log
## AICc: -1353, BIC: -1298  QS (no seasonality in final):    0  
## Box-Ljung (no autocorr.): 24.19   Shapiro (normality): 0.9938
```

### m3
Same built-in regressors as m2, plus additional terms

```
## 
## Call:
## seas(x = temp_ser_ts, xreg = cbind(vet1, chr1, jlf1), regression.aictest = NULL, 
##     regression.variables = c("tdnolpyear", "labor[3]", "easter[1]", 
##         "ls2001.Sep", "thank[3]"), forecast.maxlead = 30, seats.appendfcst = "yes", 
##     regression.usertype = c("holiday", "holiday2", "holiday3"))
## 
## Coefficients:
##                     Estimate Std. Error z value Pr(>|z|)    
## Mon               -0.0020169  0.0010327  -1.953 0.050805 .  
## Tue                0.0011790  0.0010763   1.095 0.273323    
## Wed                0.0004063  0.0010099   0.402 0.687470    
## Thu               -0.0008460  0.0010581  -0.800 0.423972    
## Fri                0.0032642  0.0010322   3.162 0.001565 ** 
## Sat                0.0051020  0.0010531   4.845 1.27e-06 ***
## Labor[3]           0.0187693  0.0026680   7.035 1.99e-12 ***
## Easter[1]         -0.0087214  0.0020526  -4.249 2.15e-05 ***
## LS2001.Sep        -0.0974056  0.0095123 -10.240  < 2e-16 ***
## Thanksgiving[3]    0.0817751  0.0298696   2.738 0.006186 ** 
## xreg1             -0.0001387  0.0046754  -0.030 0.976338    
## xreg2             -0.0127492  0.0035209  -3.621 0.000293 ***
## xreg3              0.0079217  0.0033678   2.352 0.018664 *  
## LS2001.Nov         0.0401516  0.0096231   4.172 3.01e-05 ***
## LS2008.Nov        -0.0389439  0.0095466  -4.079 4.52e-05 ***
## AR-Nonseasonal-01 -0.3374935  0.0513801  -6.569 5.08e-11 ***
## MA-Seasonal-12     0.4981432  0.0479774  10.383  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## SEATS adj.  ARIMA: (1 1 0)(0 1 1)  Obs.: 345  Transform: log
## AICc: -1367, BIC: -1301  QS (no seasonality in final):    0  
## Box-Ljung (no autocorr.): 16.03   Shapiro (normality): 0.9936
```

### Compare seasonally adjusted series from m1 and m2
Note estimate for Sep. 2015. m1 model tends to indicate Sep. was a "strong" month.  
While m2 model indicates some of that strength was holiday timing. After adjusting, underlying performance was not as strong. Said differently, we would have a high seasonal factor for Sep. 2015. We would divide the unadjusted data by that seasonal factor to get the seasonally adjusted data, which wouldn't be as strong.  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-16-1.png) 

### Compare seasonally adjusted series from m1 and m3
Again, similar to m2, m3 indicates Sep. 2015 was not as strong as m1 results would indicate.
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-17-1.png) 

### Compare seasonally adjusted series from m2 and m3
Both m2 and m3 are similar for Sep. 2015. Interestingly, m3 generally points to performance during the summer as being somewhat weaker than m2. 
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-18-1.png) 


### Seasonal factors for a particular month: Sep. Labor Day timing

Year   |   Labor Day date    
-------|----------
2011 | 5  
2012 | 3  
2013 |  2  
2014 |  1  
2015 | 7  
2016 |5  

### Seasonal factors for September  
  

date          sa1_sf   sa2_sf   sa3_sf
-----------  -------  -------  -------
2005-09-01    1.0404   1.0413   1.0369
2006-09-01    1.0390   1.0404   1.0436
2007-09-01    1.0315   1.0313   1.0290
2008-09-01    1.0354   1.0300   1.0189
2009-09-01    1.0364   1.0405   1.0405
2010-09-01    1.0377   1.0403   1.0400
2011-09-01    1.0484   1.0500   1.0450
2012-09-01    1.0341   1.0337   1.0337
2013-09-01    1.0189   1.0183   1.0192
2014-09-01    1.0249   1.0200   1.0208
2015-09-01    1.0362   1.0415   1.0424
2016-09-01    1.0388   1.0441   1.0434

### Seasonal factors for September (1987 to 2016)
Last point is Sep 2016. So both Sep. 2015 and Sep. 2016 have large seasonal factors. 
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-20-1.png) 

