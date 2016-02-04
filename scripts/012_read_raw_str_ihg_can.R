library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(xlsx, warn.conflicts=FALSE)
library(lubridate, warn.conflicts=FALSE)


#######
#
# loads the STR data from IHG on all countries, but just keeps Canada

#######
#
# name of files to read

# all history, since 1998 is coming from this input file

# used to come with all countries
#fname1 <- c("input_data/from IHG - TE Total Country-2015-07-21.xls")
# sometimes comes with just Canada
fname1 <- c("input_data/from IHG - Canada data-2016-01-22.xls")

########
#
# load STR data
#
temp1 <- read.xlsx(fname1, sheetName="Total Country", startRow=1,colIndex =1:9,
                   header = TRUE)
# filters to just Canada, making sure it's in Canadian dollars
temp2 <- temp1
raw_str_ihg_can <- temp2 %>%
  rename(country = LONG_ISO_CTRY 
         ,date=YearMonth
         ,supt=Rooms.Avail
         ,demt=Rooms.Sold
         ,rmrevt=Rooms.Rev) %>%
  select(-Country.Name,-Hotels,-Rooms) %>%
  filter(country == "CAN" & Curr.Code == "CAD") %>%
  select(-Curr.Code) %>%
  # takes from 199801 format into a date using lubridate
  mutate(country = tolower(country)
    ,date = parse_date_time(date, "%Y%m")) %>%
  # in later steps it's useful to have in Date format
  mutate(date = as.Date(date))

# puts into tidy format with a segvar column, adds country name, then 
# spreads segvar back out as column headers
a1 <- raw_str_ihg_can %>% 
  gather(segvar, value, supt:rmrevt, na.rm = FALSE) %>%
  mutate(country = paste("tot", country, sep="")) %>%
  mutate(segvar = paste(country, "_", segvar, sep="")) %>%
  select(-country) %>%
  spread(segvar, value)

str(a1)

raw_str_ihg_can <- a1

# saves Rdata version of the data
save(raw_str_ihg_can, file="output_data/raw_str_ihg_can.Rdata")
