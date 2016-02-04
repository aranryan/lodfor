
# reads in a us forecast from an excel file and saves as an Rdata file

library(xts, warn.conflicts=FALSE)
library(readxl, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)

forwb <- c(paste("~/Project/lodging forecast/STR - Jan 2016/working/", "output_q_STR_2016Jan6", ".xlsx", sep=""))

tempb <- read_excel(forwb, sheet=1, col_names=TRUE, skip=0)
names(tempb)[1] <- "date"


# removes columns that are all NA
b <- Filter(function(x)!all(is.na(x)), tempb)
# takes columns except the date column
c <- b[,2:ncol(b)]
# keeps only those columns where the sum is not equal to zero
d <- c[, colSums(c) != 0] 
usfor_q <- cbind(b[1],d) %>%
  mutate(date = as.Date(date)) %>%
  read.zoo() %>%
  xts()

k <- duplicated(colnames(d))
k
# saves Rdata versions of the output files
save(usfor_q, file="output_data/usfor_q.Rdata")
