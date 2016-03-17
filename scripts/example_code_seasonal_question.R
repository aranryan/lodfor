# example code I used in asking question posted on 
#https://github.com/christophsax/seasonal/issues/157


library(seasonal)
library(xts)

# code from Example 7.14 at
# http://www.seasonal.website/examples.html#seats

mmod1 <- seas(AirPassengers, 
              regression.aictest = "td",
              outlier.types = c("ao", "ls", "tc"),
              forecast.maxlead = 36
)
# accessing s16 as combined seasonal factors
tail(as.xts(series(mmod1, "s16")), 48)

# same code, but with line added to append forecast
mmod2 <- seas(AirPassengers, 
              regression.aictest = "td",
              outlier.types = c("ao", "ls", "tc"),
              forecast.maxlead = 36,
              seats.appendfcst="yes"
)
tail(as.xts(series(mmod2, "s16")), 48)

# same code, but with line added to append forecast
mmod3 <- seas(AirPassengers, 
              regression.aictest = "td",
              outlier.types = c("ao", "ls", "tc"),
              forecast.maxlead = 48,
              seats.appendfcst="yes"
)
tail(as.xts(series(mmod3, "s16")), 48)

install.packages("x13binary")
