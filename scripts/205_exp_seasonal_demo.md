# Seasonal adjustment demo
Tourism Economics  
January 9, 2016  










### Set up data to run using: totus_demd

  
## Run seasonal adjustment
### Summary results  
Uses default settings. For example, includes a term for Easter.

```
## 
## Call:
## seas(x = temp_ser_ts, forecast.maxlead = 30, seats.appendfcst = "yes")
## 
## Coefficients:
##                     Estimate Std. Error z value Pr(>|z|)    
## Mon               -3.937e-03  1.367e-03  -2.880 0.003976 ** 
## Tue                2.260e-03  1.377e-03   1.641 0.100877    
## Wed               -8.937e-05  1.368e-03  -0.065 0.947919    
## Thu               -7.419e-04  1.363e-03  -0.544 0.586113    
## Fri                4.919e-03  1.363e-03   3.607 0.000309 ***
## Sat                3.550e-03  1.370e-03   2.590 0.009593 ** 
## Easter[1]         -8.529e-03  2.820e-03  -3.025 0.002489 ** 
## LS2001.Sep        -9.352e-02  1.236e-02  -7.564  3.9e-14 ***
## AR-Nonseasonal-01 -4.164e-01  4.940e-02  -8.429  < 2e-16 ***
## AR-Seasonal-12     2.170e-01  7.733e-02   2.806 0.005020 ** 
## MA-Seasonal-12     7.569e-01  5.203e-02  14.549  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## SEATS adj.  ARIMA: (1 1 0)(1 1 1)  Obs.: 345  Transform: log
## AICc: -1205, BIC: -1160  QS (no seasonality in final):    0  
## Box-Ljung (no autocorr.): 31.53   Shapiro (normality): 0.9893 *
```




## Series codes for use in examples

code | description
-----|----------------------
oa1 | original series  
sa1 | seasonally adjusted series  
sa1_sf | final combined (seasonal/trading day/holiday) factors (s16)  
oa1_b | original = seasonally adjusted series \* combined (seasonal/trading day/holiday) adjustment factors

### Example calculations
In this table we can get back to the original series as follows:  

- oa1_b = sa1 \* sa1_sf  
  
which is equivalent to:  
  
- oa1_b = seasonally adjusted series \* combined (seasonal/trading day/holiday) adjustment factors
  
  

date             oa1      sa1   sa1_sf    oa1_b
-----------  -------  -------  -------  -------
2014-09-01    3.2567   3.1776   1.0249   3.2567
2014-10-01    3.3600   3.2014   1.0496   3.3600
2014-11-01    2.8822   3.2065   0.8989   2.8822
2014-12-01    2.5750   3.2389   0.7950   2.5750
2015-01-01    2.6575   3.2362   0.8212   2.6575
2015-02-01    3.0471   3.2404   0.9404   3.0471
2015-03-01    3.2816   3.2373   1.0137   3.2816
2015-04-01    3.3033   3.2453   1.0179   3.3033
2015-05-01    3.3634   3.2458   1.0362   3.3634
2015-06-01    3.6505   3.2505   1.1230   3.6505
2015-07-01    3.7678   3.2598   1.1558   3.7678
2015-08-01    3.5386   3.2444   1.0907   3.5386




### Seasonal factors for September
Take the estimate of the annualized level, and multiply by the seasonal factor, to get the actual level

date             oa1      sa1   sa1_sf    oa1_b  month 
-----------  -------  -------  -------  -------  ------
2004-09-01    2.8342   2.7506   1.0304   2.8342  Sep   
2005-09-01    2.9259   2.8124   1.0404   2.9259  Sep   
2006-09-01    2.9068   2.7978   1.0390   2.9068  Sep   
2007-09-01    2.9177   2.8287   1.0315   2.9177  Sep   
2008-09-01    2.7988   2.7030   1.0354   2.7988  Sep   
2009-09-01    2.6873   2.5930   1.0364   2.6873  Sep   
2010-09-01    2.9045   2.7991   1.0376   2.9045  Sep   
2011-09-01    3.0747   2.9327   1.0484   3.0747  Sep   
2012-09-01    3.0944   2.9924   1.0341   3.0944  Sep   
2013-09-01    3.1140   3.0565   1.0188   3.1140  Sep   
2014-09-01    3.2567   3.1776   1.0249   3.2567  Sep   
2015-09-01    3.4035   3.2847   1.0362   3.4035  Sep   


### Seasonal factors by month (1987 to 2015)
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-9-1.png)\


# How does it help us?  

## Converting quarterly to monthly using seasonal factors




### Monthly series and seasonal factors: Table  


date           oa1      sa1   sa1_sf
---------  -------  -------  -------
Oct 2014    3.3600   3.2014   1.0496
Nov 2014    2.8822   3.2065   0.8989
Dec 2014    2.5750   3.2389   0.7950
Jan 2015    2.6575   3.2362   0.8212
Feb 2015    3.0471   3.2404   0.9404
Mar 2015    3.2816   3.2373   1.0137
Apr 2015    3.3033   3.2453   1.0179
May 2015    3.3634   3.2458   1.0362
Jun 2015    3.6505   3.2505   1.1230
Jul 2015    3.7678   3.2598   1.1558
Aug 2015    3.5386   3.2444   1.0907
Sep 2015    3.4035   3.2847   1.0362

### Monthly series and seasonally adjusted series: Graph  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-12-1.png)\


### Quarterly series and seasonal factors: Table  
  

date           oa1      sa1   sa1_sf
---------  -------  -------  -------
Oct 2012    2.7430   3.0051   0.9128
Jan 2013    2.7824   3.0141   0.9231
Apr 2013    3.2186   3.0280   1.0630
Jul 2013    3.3351   3.0363   1.0984
Oct 2013    2.8044   3.0708   0.9132
Jan 2014    2.8790   3.1149   0.9243
Apr 2014    3.3501   3.1524   1.0627
Jul 2014    3.4848   3.1757   1.0973
Oct 2014    2.9397   3.2169   0.9138
Jan 2015    2.9937   3.2364   0.9250
Apr 2015    3.4382   3.2369   1.0622
Jul 2015    3.5718   3.2568   1.0967

### Quarterly series and seasonally adjusted series: Graph 
  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-14-1.png)\


### Use quarterly to estimate monthly

Use the seasonally adjusted quarterly data, and the monthly seasonal factors, to estimate monthly un-adjusted series.  
"oa1q" to indicate non-seasonally adjusted data ("oa1") coming from quarterly data ("q").  
  
- oa1q = sa1q * sa1_sf
  
We observe that oa1q is quite similar to oa1, which is the original monthly data. This implies that if we have a reasonable estimate of quarterly data, then we can use monthly seasonal factors to get to accurate monthly estimates.

date          oa1     sa1   sa1_sf    sa1q    oa1q   oa1_pchya   oa1q_pchya
---------  ------  ------  -------  ------  ------  ----------  -----------
Sep 2014    3.257   3.178    1.025   3.176   3.255       4.58%        5.22%
Oct 2014    3.360   3.201    1.050   3.217   3.376       5.84%        5.55%
Nov 2014    2.882   3.207    0.899   3.217   2.892       3.10%        3.61%
Dec 2014    2.575   3.239    0.795   3.217   2.557       5.42%        5.82%
Jan 2015    2.658   3.236    0.821   3.236   2.658       4.87%        4.47%
Feb 2015    3.047   3.240    0.940   3.236   3.043       4.02%        4.08%
Mar 2015    3.282   3.237    1.014   3.236   3.281       3.25%        3.62%
Apr 2015    3.303   3.245    1.018   3.237   3.295       2.93%        2.30%
May 2015    3.363   3.246    1.036   3.237   3.354       1.78%        1.92%
Jun 2015    3.650   3.251    1.123   3.237   3.635       3.18%        3.02%
Jul 2015    3.768   3.260    1.156   3.257   3.764       3.51%        3.07%
Aug 2015    3.539   3.244    1.091   3.257   3.552      -0.33%        0.79%


### Monthly data, comparison between original and oa1q
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-16-1.png)\


### Monthly data, comparison between original and oa1q
Percentage change from prior year  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-17-1.png)\


### Regression, monthly levels  
oa1q explains almost all variation in oa1

```
## 
## Call:
## lm(formula = oa1 ~ oa1q, data = tempm1)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.124636 -0.007817  0.000185  0.009149  0.139771 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -0.005517   0.005820  -0.948    0.344    
## oa1q         1.002293   0.002253 444.789   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.01936 on 343 degrees of freedom
##   (88 observations deleted due to missingness)
## Multiple R-squared:  0.9983,	Adjusted R-squared:  0.9983 
## F-statistic: 1.978e+05 on 1 and 343 DF,  p-value: < 2.2e-16
```


### Regression, monthly percentage change from prior year  
oa1q explains a large proportion of the variation in oa1

```
## 
## Call:
## lm(formula = oa1_pchya ~ oa1q_pchya, data = tempm1)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.058832 -0.004934  0.000115  0.005187  0.051755 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 0.0017652  0.0006996   2.523   0.0121 *  
## oa1q_pchya  0.9124910  0.0176608  51.667   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.01096 on 331 degrees of freedom
##   (100 observations deleted due to missingness)
## Multiple R-squared:  0.8897,	Adjusted R-squared:  0.8894 
## F-statistic:  2670 on 1 and 331 DF,  p-value: < 2.2e-16
```

