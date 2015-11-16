# Untitled
Tourism Economics  
November 13, 2015  













```
##          totus_demd
## Jan 1987   1.481879
## Feb 1987   1.746900
## Mar 1987   1.875177
## Apr 1987   1.866738
## May 1987   1.903070
## Jun 1987   2.128505
```

```
## 
## Call:
## seas(x = temp_ser_ts, forecast.save = "fct")
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

```
## 
## Call:
## seas(x = temp_ser_ts, transform.function = "log", regression.aictest = NULL, 
##     outlier = NULL, regression.variables = c("td", "easter[1]", 
##         "ls2001.Sep"), arima.model = "(1 1 0)(1 1 1)")
## 
## Coefficients:
##                     Estimate Std. Error z value Pr(>|z|)    
## Mon               -3.929e-03  1.369e-03  -2.870 0.004109 ** 
## Tue                2.241e-03  1.379e-03   1.624 0.104279    
## Wed               -7.323e-05  1.370e-03  -0.053 0.957379    
## Thu               -7.482e-04  1.365e-03  -0.548 0.583517    
## Fri                4.930e-03  1.366e-03   3.610 0.000306 ***
## Sat                3.533e-03  1.373e-03   2.574 0.010050 *  
## Easter[1]         -8.534e-03  2.824e-03  -3.022 0.002513 ** 
## LS2001.Sep        -9.349e-02  1.238e-02  -7.554 4.22e-14 ***
## AR-Nonseasonal-01 -4.168e-01  4.939e-02  -8.438  < 2e-16 ***
## AR-Seasonal-12     2.160e-01  7.732e-02   2.794 0.005204 ** 
## MA-Seasonal-12     7.568e-01  5.202e-02  14.549  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## SEATS adj.  ARIMA: (1 1 0)(1 1 1)  Obs.: 345  Transform: log
## AICc: -1204, BIC: -1160  QS (no seasonality in final):    0  
## Box-Ljung (no autocorr.): 31.49   Shapiro (normality): 0.9894 *
```


## fundamental identities of seasonal adjustment
Y = T * I * (S * TD)
all.equal(AirPassengers,  
series(m, "seats.trend") *
         series(m, "seats.irregular") * series(m, "seats.adjustfac"))


Name   |   Small   | Description of table  
-------|----------|------------------------------
trend  |   s12    | final SEATS trend component  
seasonal |  s10    | final SEATS seasonal component  
irregular | s13   |  final SEATS irregular component  
seasonaladj | s11 | final SEATS seasonal adjustment component   
transitory | s14 | final SEATS transitory component   
adjustfac | s16 | final SEATS combined adjustment factors  
adjustmentratio | s18 | final SEATS adjustment ratio  
trendfcstdecomp | tfd | forecast of the trend component  
seasonalfcstdecomp |  sfd | forecast of the seasonal component  
seriesfcstdecomp | ofd | forecast of the series component  
seasonaladjfcstdecomp | afd | forecast of the final SEATS seasonal adjustment  
transitoryfcstdecomp | yfd | forecast of the transitory component  
seasadjconst |  sec | final SEATS seasonal adjustment with constant term included  
trendconst | stc | final SEATS trend component with constant term included  
totaladjustment | sta |total adjustment factors for SEATS seasonal adjustment  



code | description
-----|----------------------
oa1 | original series  
sa1 | seasonally adjusted series  
sa1_trend | trend component (s12)
sa1_seasonal | seasonal component (s10)  
sa1_irregular | irregular component (s13)  
sa1_sf | final combined (seasonal/trading day/holiday) factors (s16)  
oa1_a | original = trend * irregular * combined (seasonal/trading day/holiday) adjustment factors
oa1_b | original = seasonally adjusted series * combined (seasonal/trading day/holiday) adjustment factors

### Example calculations
In this table we have two ways to get back to the original series.   
* oa1_a = trend * irregular * combined (seasonal/trading day/holiday) adjustment factors or   
* oa1_b = seasonally adjusted series * combined (seasonal/trading day/holiday) adjustment factors
  


date             oa1      sa1   sa1_trend   sa1_seasonal   sa1_irregular   sa1_sf    oa1_a    oa1_b
-----------  -------  -------  ----------  -------------  --------------  -------  -------  -------
2014-10-01    3.3616   3.2023      3.2016         1.0455          1.0002   1.0498   3.3616   3.3616
2014-11-01    2.8817   3.2070      3.2139         0.9007          0.9979   0.8986   2.8817   2.8817
2014-12-01    2.5759   3.2399      3.2257         0.7965          1.0044   0.7951   2.5759   2.5759
2015-01-01    2.6576   3.2365      3.2337         0.8148          1.0009   0.8211   2.6576   2.6576
2015-02-01    3.0474   3.2406      3.2380         0.9488          1.0008   0.9404   3.0474   3.0474
2015-03-01    3.2823   3.2377      3.2413         1.0192          0.9989   1.0138   3.2823   3.2823
2015-04-01    3.3039   3.2458      3.2446         1.0210          1.0004   1.0179   3.3039   3.3039
2015-05-01    3.3637   3.2463      3.2482         1.0336          0.9994   1.0362   3.3637   3.3637
2015-06-01    3.6511   3.2511      3.2524         1.1249          0.9996   1.1230   3.6511   3.6511
2015-07-01    3.7683   3.2603      3.2569         1.1511          1.0010   1.1558   3.7683   3.7683
2015-08-01    3.5391   3.2450      3.2635         1.0976          0.9944   1.0906   3.5391   3.5391
2015-09-01    3.4047   3.2858      3.2730         1.0339          1.0039   1.0362   3.4047   3.4047

## So which are the seasonal factors?

It's sometimes hard to get a clear understanding from the documentation.  
I've seen reference to the "combined" factors in the D16 (and presumably also s16) table as being the __combined__ (seasonal/trading day/holiday) factors. 

There is also reference to a "total adjustment factors for SEATS seasonal adjustment".


date             oa1      sa1   sa1_trend   sa1_seasonal   sa1_irregular   sa1_sf   sa1_total
-----------  -------  -------  ----------  -------------  --------------  -------  ----------
2014-10-01    3.3616   3.2023      3.2016         1.0455          1.0002   1.0498      1.0498
2014-11-01    2.8817   3.2070      3.2139         0.9007          0.9979   0.8986      0.8986
2014-12-01    2.5759   3.2399      3.2257         0.7965          1.0044   0.7951      0.7951
2015-01-01    2.6576   3.2365      3.2337         0.8148          1.0009   0.8211      0.8211
2015-02-01    3.0474   3.2406      3.2380         0.9488          1.0008   0.9404      0.9404
2015-03-01    3.2823   3.2377      3.2413         1.0192          0.9989   1.0138      1.0138
2015-04-01    3.3039   3.2458      3.2446         1.0210          1.0004   1.0179      1.0179
2015-05-01    3.3637   3.2463      3.2482         1.0336          0.9994   1.0362      1.0362
2015-06-01    3.6511   3.2511      3.2524         1.1249          0.9996   1.1230      1.1230
2015-07-01    3.7683   3.2603      3.2569         1.1511          1.0010   1.1558      1.1558
2015-08-01    3.5391   3.2450      3.2635         1.0976          0.9944   1.0906      1.0906
2015-09-01    3.4047   3.2858      3.2730         1.0339          1.0039   1.0362      1.0362






### graph title

![](../output_data/figure_exp_seasonal_short/fig-unnamed-chunk-8-1.png) 

