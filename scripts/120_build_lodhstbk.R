
library(arlodr, warn.conflicts=FALSE)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(lubridate, warn.conflicts=FALSE)

#######
#
# define functions
simp_xts <- function(x, y){
  y <- x %>%
    gather(var, value, -date, -area_sh) %>%
    mutate(vargeo = paste(var, area_sh, sep="_")) %>%
    select(date, vargeo, value) %>%
    spread(vargeo, value) %>%
    read.zoo(regular=TRUE) %>%
    xts()
}

##############

# lodging data
load("output_data/out_t_hststr.Rdata")
temp1_lodhstbk_q <- out_t_hststr

#########
#
# creates annual dataframe
# follows approach used in create_ushist rather than in 
# fred

# the underlying demt, supt, and rmrevt should all be summed
# and then used to calculate occ, adr, and revpar

# select series that should be converted to annual by summing
# I wrote a regular expression that is looking for certain text strings
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
suma <- data.frame(temp1_lodhstbk_q) %>%
  select(date, area_sh, matches("^demt|^supt|^rmrevt")) %>%
  gather(var, value, -area_sh, -date) %>%
  mutate(vargeo = paste(var, area_sh, sep="_")) %>%
  select(date, vargeo, value) %>%
  spread(vargeo, value) %>%
  read.zoo(regular=TRUE) %>%
  xts()

# I think the q_to_a function needs the data to end with a fourth quarter
suma_fullyr <- suma %>%
  data.frame(date=time(.), .) %>%
  mutate(year = year(date), month = month(date)) %>%
  select(date, year, month, everything()) %>%
  # filters to include only rows that are the fourth quarter
  filter(month == 10) %>%
  read.zoo(regular=TRUE) %>%
  xts()
# takes end date of the filtered xts object
suma_fullyr <- end(suma_fullyr)
# reduces suma to end with the last full year
suma <- window(suma, start = start(suma), end = as.Date(suma_fullyr))

# this function is one I defined, it converts all the columns in 
# an xts object to annual. Must be an xts object to start with
suma <- q_to_a_xts(suma, type="sum")

# takes the summed data and spreads it into a tidy format with
# tidyr and then calculates the occupancy and revpar series
# first needs to go from xts to dataframe
temp1_lodhstbk_a <- data.frame(date=time(suma), suma)%>% 
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
  gather(varseg, value, -date, na.rm = FALSE) %>%
  # in the following the ^ means anything not in the list
  # with the list being all characters and numbers
  # so it separates segvar into two colums using sep
  separate(varseg, c("varseg", "area_sh"), sep = "[^[:alnum:]]+") %>%
  separate(varseg, c("variable", "seg"), sep = -4) %>%
  # keeps seg as a column and spreads variable into multiple columns containing
  # containint the values
  spread(variable,value) %>%
  # adds new calculated column
  mutate(occ = demt / supt) %>%
  # adds another column
  mutate(revpar = rmrevt / supt) %>%
  mutate(adr = rmrevt / demt) %>%
  gather(var, value, -date, -area_sh, -seg) %>%
  mutate(varseg = paste(var, seg, sep="")) %>%
  select(date, area_sh, varseg, value) %>%
  spread(varseg, value)

########
#
# step of converting mbk_q and mbk_a to regular zoo object
# and then back to dataframe on the assumption it would ensure
# NAs for any missing data points
# works when I tested it by deleting a row that had Miami data for
# 2007-07-01, then it shows up as NA. But it didn't depend on whether
# it was done as zoo regular=TRUE or FALSE. I think that's because
# I had only deleted a row that was data for a particular area_sh
# So the other areas still had that date, so it wasn't so much a missing
# date as a missing data point. 
# mbk_q_test <- rbind(mbk_q[1:998,], mbk_q[1000:nrow(mbk_q),])
# mbk_q_x$gdptotlcc_mimfl

# converts to zoo regular and then xts using a function, then puts it back
# into the same tidy format it was in before
lodhstbk_q <- temp1_lodhstbk_q %>%
  simp_xts() %>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date) %>%
  separate(variable, c("variable", "area_sh"), sep = "_(?!.*_)", extra="merge") %>%
  spread(variable, value)

lodhstbk_a <- temp1_lodhstbk_a %>%
  simp_xts() %>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date) %>%
  separate(variable, c("variable", "area_sh"), sep = "_(?!.*_)", extra="merge") %>%
  spread(variable, value)

######
#
# put together mbk as a list with several components

lodhstbk <- list(lodhstbk_q=lodhstbk_q, lodhstbk_a=lodhstbk_a)
save(lodhstbk, file="output_data/lodhstbk.Rdata")
