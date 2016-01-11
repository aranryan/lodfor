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
2014-09-01    3.2561   3.1770   1.0249   3.2561
2014-10-01    3.3616   3.2023   1.0498   3.3616
2014-11-01    2.8817   3.2070   0.8986   2.8817
2014-12-01    2.5759   3.2399   0.7951   2.5759
2015-01-01    2.6576   3.2365   0.8211   2.6576
2015-02-01    3.0474   3.2406   0.9404   3.0474
2015-03-01    3.2823   3.2377   1.0138   3.2823
2015-04-01    3.3039   3.2458   1.0179   3.3039
2015-05-01    3.3637   3.2463   1.0362   3.3637
2015-06-01    3.6511   3.2511   1.1230   3.6511
2015-07-01    3.7683   3.2603   1.1558   3.7683
2015-08-01    3.5391   3.2450   1.0906   3.5391




### Seasonal factors for September
Take the estimate of the annualized level, and multiply by the seasonal factor, to get the actual level

date             oa1      sa1   sa1_sf    oa1_b  month 
-----------  -------  -------  -------  -------  ------
2004-09-01    2.8340   2.7504   1.0304   2.8340  Sep   
2005-09-01    2.9258   2.8122   1.0404   2.9258  Sep   
2006-09-01    2.9067   2.7976   1.0390   2.9067  Sep   
2007-09-01    2.9175   2.8285   1.0315   2.9175  Sep   
2008-09-01    2.7987   2.7030   1.0354   2.7987  Sep   
2009-09-01    2.6872   2.5929   1.0364   2.6872  Sep   
2010-09-01    2.9044   2.7990   1.0377   2.9044  Sep   
2011-09-01    3.0746   2.9326   1.0484   3.0746  Sep   
2012-09-01    3.0943   2.9923   1.0341   3.0943  Sep   
2013-09-01    3.1141   3.0563   1.0189   3.1141  Sep   
2014-09-01    3.2561   3.1770   1.0249   3.2561  Sep   
2015-09-01    3.4047   3.2858   1.0362   3.4047  Sep   


### Seasonal factors by month (1987 to 2015)
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-9-1.png) 

# How does it help us?  

## Converting quarterly to monthly using seasonal factors




### Monthly series and seasonal factors: Table  


date           oa1      sa1   sa1_sf
---------  -------  -------  -------
Oct 2014    3.3616   3.2023   1.0498
Nov 2014    2.8817   3.2070   0.8986
Dec 2014    2.5759   3.2399   0.7951
Jan 2015    2.6576   3.2365   0.8211
Feb 2015    3.0474   3.2406   0.9404
Mar 2015    3.2823   3.2377   1.0138
Apr 2015    3.3039   3.2458   1.0179
May 2015    3.3637   3.2463   1.0362
Jun 2015    3.6511   3.2511   1.1230
Jul 2015    3.7683   3.2603   1.1558
Aug 2015    3.5391   3.2450   1.0906
Sep 2015    3.4047   3.2858   1.0362

### Monthly series and seasonal factors: Graph  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-12-1.png) 


### Quarterly series and seasonal factors: Table  
  

date           oa1      sa1   sa1_sf
---------  -------  -------  -------
Oct 2012    2.7430   3.0055   0.9127
Jan 2013    2.7825   3.0140   0.9232
Apr 2013    3.2186   3.0279   1.0630
Jul 2013    3.3352   3.0361   1.0985
Oct 2013    2.8014   3.0681   0.9131
Jan 2014    2.8787   3.1145   0.9243
Apr 2014    3.3499   3.1521   1.0628
Jul 2014    3.4846   3.1753   1.0974
Oct 2014    2.9404   3.2181   0.9137
Jan 2015    2.9940   3.2366   0.9250
Apr 2015    3.4387   3.2373   1.0622
Jul 2015    3.5725   3.2573   1.0968

### Quarterly series and seasonal factors: Graph 
  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-14-1.png) 


### Use quarterly to estimate monthly

Use the seasonally adjusted quarterly data, and the monthly seasonal factors, to estimate monthly un-adjusted series.  
"oa1q" to indicate non-seasonally adjusted data ("oa1") coming from quarterly data ("q").  
  
- oa1q = sa1q * sa1_sf
  
We observe that oa1q is quite similar to oa1, which is the original monthly data. This implies that if we have a reasonable estimate of quarterly data, then we can use monthly seasonal factors to get to accurate monthly estimates.

date          oa1     sa1   sa1_sf    sa1q    oa1q   oa1_pchya   oa1q_pchya
---------  ------  ------  -------  ------  ------  ----------  -----------
Sep 2014    3.256   3.177    1.025   3.175   3.254       4.56%        5.20%
Oct 2014    3.362   3.202    1.050   3.218   3.378       6.00%        5.74%
Nov 2014    2.882   3.207    0.899   3.218   2.892       3.20%        3.75%
Dec 2014    2.576   3.240    0.795   3.218   2.559       5.56%        6.00%
Jan 2015    2.658   3.237    0.821   3.237   2.658       4.90%        4.49%
Feb 2015    3.047   3.241    0.940   3.237   3.044       4.04%        4.10%
Mar 2015    3.282   3.238    1.014   3.237   3.281       3.27%        3.63%
Apr 2015    3.304   3.246    1.018   3.237   3.295       2.95%        2.31%
May 2015    3.364   3.246    1.036   3.237   3.354       1.81%        1.94%
Jun 2015    3.651   3.251    1.123   3.237   3.635       3.20%        3.04%
Jul 2015    3.768   3.260    1.156   3.257   3.765       3.53%        3.10%
Aug 2015    3.539   3.245    1.091   3.257   3.553      -0.32%        0.80%

### Monthly data, comparison between original and oa1q
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-16-1.png) 

### Monthly data, comparison between original and oa1q
Percentage change from prior year  
![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-17-1.png) 

### Regression, monthly levels  
oa1q explains almost all variation in oa1

```
## 
## Call:
## lm(formula = oa1 ~ oa1q, data = tempm1)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.124650 -0.007857  0.000209  0.009152  0.139669 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -0.005544   0.005824  -0.952    0.342    
## oa1q         1.002305   0.002255 444.528   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.01937 on 343 degrees of freedom
##   (88 observations deleted due to missingness)
## Multiple R-squared:  0.9983,	Adjusted R-squared:  0.9983 
## F-statistic: 1.976e+05 on 1 and 343 DF,  p-value: < 2.2e-16
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
## -0.058853 -0.004922  0.000126  0.005171  0.051723 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 0.0017639  0.0006998   2.521   0.0122 *  
## oa1q_pchya  0.9125414  0.0176641  51.661   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.01097 on 331 degrees of freedom
##   (100 observations deleted due to missingness)
## Multiple R-squared:  0.8897,	Adjusted R-squared:  0.8893 
## F-statistic:  2669 on 1 and 331 DF,  p-value: < 2.2e-16
```

