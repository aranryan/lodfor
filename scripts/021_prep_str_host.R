library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)


#########################################
#
# Host market data

load("output_data/raw_str_us_host.Rdata")
temp_str_us_host <- load_str(raw_str_us_host)

# these two data frames are the working data frames and become the outputs
str_us_host_m <- temp_str_us_host[[1]]
str_us_host_q <- temp_str_us_host[[2]]

# loads seasonal factors
# temporarily commmented these out in 2016-Nov so that I could cobble
# together factors
#load("output_data/str_us_host_m_factors.Rdata")
#load("output_data/str_us_host_q_factors.Rdata")

load("output_data/str_us_host_q_factors_2016-11-07.Rdata")
load("output_data/str_us_host_select_q_factors.Rdata")

# combine the two files
str_us_host_q_factors <- str_us_host_q_factors %>%
  left_join(str_us_host_select_q_factors, by=c("date"))


# ############
# #
# # create monthly sa from seasonal factors using a function
# #
# 
# # temporarily not merging on monthly seasonal factors for host data because 
# # they haven't been estimated
# # str_us_host_m1 <- merge(str_us_host_m, str_us_host_m_factors, all=TRUE, by="date")
# str_us_host_m1 <- str_us_host_m
# 
# # set up dataframe with variable columns such as occ, demd, occ_sf.
# # it is flexible whether how many geographic and segment columns exist
# str_us_host_m2 <- str_us_host_m1 %>%
#   # creates column called segvar that contains the column names, and one next to 
#   # it with the values, dropping the time column
#   gather(segvar, value, -date, na.rm = FALSE) %>%
#   # this process of separating out the variables is a bit customized because
#   # I couldn't learn a reliable way to break off the lodging variable names
#   # in a generalized approach, so I did it in a way that I can customize based on 
#   # how many concepts are wrapped into segvar
#   separate(segvar, c("seg", "variable"), sep = "_", extra="merge") %>%
#   separate(variable, c("area_sh", "variable"), sep = "_", extra="merge") %>%
#   separate(variable, c("country", "variable"), sep = "_", extra="merge") %>%
#   # keeps everything else as columns and spreads variable into multiple 
#   # columns containing the values
#   spread(variable,value)
# 
# # temporary placeholder given I didn't bring in monthly seasonal factors
# # this just pads it with a bunch of NAs
# str_us_host_m2 <- str_us_host_m2 %>%
#   mutate(occ_sf = NA, adr_sf = NA, revpar_sf = NA, demd_sf = NA, supd_sf = NA)
# 
# # applies a function to calculate certain sa series, and then 
# out_str_us_host_m <- str_us_host_m2 %>%
#   create_sa_str() %>%
#   mutate(segvar = paste(seg, area_sh, country, sep="_")) %>%
#   select(-seg, -area_sh, -country) %>%
#   gather(variable, value, -date, -segvar) %>%
#   mutate(segvar = paste(segvar, variable, sep="_")) %>%
#   select(-variable) %>%
#   spread(segvar, value) %>%
#   read.zoo() %>%
#   xts()


############
#
# create quarterly sa from seasonal factors using a function

# merge on the seasonal factors
str_us_host_q1 <- merge(str_us_host_q, str_us_host_q_factors, all=TRUE)

# set up dataframe with variable columns such as occ, demd, occ_sf.
# it is flexible whether how many geographic and segment columns exist
str_us_host_q2 <- str_us_host_q1 %>%
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # this process of separating out the variables is a bit customized because
  # I couldn't learn a reliable way to break off the lodging variable names
  # in a generalized approach, so I did it in a way that I can customize based on 
  # how many concepts are wrapped into segvar
  separate(segvar, c("seg", "variable"), sep = "_", extra="merge") %>%
  separate(variable, c("area_sh", "variable"), sep = "_", extra="merge") %>%
  separate(variable, c("country", "variable"), sep = "_", extra="merge") %>%
  # keeps everything else as columns and spreads variable into multiple 
  # columns containing the values
  spread(variable,value)

# applies a function to calculate certain sa series
out_str_us_host_q <- str_us_host_q2 %>%
  create_sa_str() %>%
  mutate(segvar = paste(seg, area_sh, country, sep="_")) %>%
  select(-seg, -area_sh, -country) %>%
  gather(variable, value, -date, -segvar) %>%
  mutate(segvar = paste(segvar, variable, sep="_")) %>%
  select(-variable) %>%
  spread(segvar, value) %>%
  read.zoo() %>%
  xts()

# just to take a peek for troubleshooting purposes
a <- out_str_us_host_q %>%
  data.frame(date=time(.), .) %>%
  gather(variable, value, -date)

#########################
#
# writing outputs
#

# writes csv versions of the output files
# write.zoo(out_str_us_host_m, file="output_data/out_str_us_host_m.csv", sep=",")
write.zoo(out_str_us_host_q, file="output_data/out_str_us_host_q.csv", sep=",")

# saves Rdata versions of the output files
# save(out_str_us_host_m, file="output_data/out_str_us_host_m.Rdata")
save(out_str_us_host_q, file="output_data/out_str_us_host_q.Rdata")
