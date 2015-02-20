
# reads in a us forecast from an excel file and saves as an Rdata file

require(XLConnect)

# using XLConnect, which happened to work
forwb <- c(paste("~/Project/lodging forecast/STR - Jan 2015/working/", "output_q_STR_2015Janv7", ".xlsx", sep=""))

wb = loadWorkbook(forwb)
setMissingValue(wb, value = c("NA"))
tempa <- readWorksheet(wb, sheet="Sheet1", startRow=1, endRow=100, startCol=1, 
                       endCol=200, header = TRUE)
names(tempa)[1] <- "date"
# removes columns that are all NA
b <- Filter(function(x)!all(is.na(x)), tempa)
# takes columns except the date column
c <- b[,2:ncol(b)]
# keeps only those columns where the sum is not equal to zero
d <- c[, colSums(c) != 0] 
usfor_q <- cbind(b[1],d) %>%
  read.zoo() %>%
  xts()

# saves Rdata versions of the output files
save(usfor_q, file="output_data/usfor_q.Rdata")
