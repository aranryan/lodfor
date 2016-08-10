library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(readxl, warn.conflicts=FALSE)
library(lubridate, warn.conflicts=FALSE)


#######
#
# loads the STR data from IHG on all countries, but just keeps Canada

#######
#
# name of files to read

# all history, since 1998 is coming from this input file

# sometimes comes with all countries
# remember to open save Excel file so that it reads the rooms column
fname1 <- c("input_data/from IHG - TE Country Report-2016-08-01.xls")
# sometimes comes with just Canada
#fname1 <- c("input_data/from IHG - Canada data-2016-01-22.xls")

########
#
# load STR data
#
temp1 <- read_excel(fname1, sheet=2, col_names = TRUE)

colnames(temp1) <- colnames(temp1) %>%
  tolower() %>%
  gsub("\\.", "\\_", .) %>%
  gsub(" ", "_", .)

# filters to just Canada, making sure it's in Canadian dollars
temp2 <- temp1
temp3 <- temp2 %>%
  rename(country = long_iso_ctry 
         ,date=yearmonth
         ,supt=rooms_avail
         ,demt=rooms_sold
         ,rmrevt=rooms_rev) %>%
  # strange, sometimes doesn't read in rooms column. Just save the Excel
  # file again and that seems to fix the problem.
  select(-country_name,-hotels, -rooms) %>%
  filter(country == "CAN" & curr_code == "CAD") %>%
  select(-curr_code) %>%
  
  # takes from 199801 format into a date using lubridate
  mutate(country = tolower(country),
    date = as.Date(as.yearmon(format(date, nsmall =2), "%Y%m")))

# puts into tidy format with a segvar column, adds country name, then 
# spreads segvar back out as column headers
raw_str_ihg_can <- temp3 %>% 
  gather(segvar, value, supt:rmrevt, na.rm = FALSE) %>%
  mutate(country = paste("tot", country, sep="")) %>%
  mutate(segvar = paste(country, "_", segvar, sep="")) %>%
  select(-country) %>%
  spread(segvar, value)


# saves Rdata version of the data
save(raw_str_ihg_can, file="output_data/raw_str_ihg_can.Rdata")
