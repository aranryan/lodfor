
# reads in a us forecast from an excel file and saves as an Rdata file

library(xts, warn.conflicts=FALSE)
library(readxl, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)

forwb <- c(paste("~/Project/lodging forecast/STR - Jan 2016/working/", "output_q_STR_2016Jan12", ".xlsx", sep=""))

tempb <- read_excel(forwb, sheet=1, col_names=TRUE, skip=0)
colnames(tempb)[1] <- "date"


# removes columns that are all NA
b <- Filter(function(x)!all(is.na(x)), tempb)
# removes columns that are all 0
c <- b[, colSums(b != 0, na.rm = TRUE) > 0]

usfor_q <- c %>%
  data.frame() %>%
  mutate(date = as.Date(date)) %>%
  read.zoo() %>%
  xts()

k <- duplicated(colnames(c))
k
# saves Rdata versions of the output files
save(usfor_q, file="output_data/usfor_q.Rdata")
