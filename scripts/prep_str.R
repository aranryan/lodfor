
###############
#
# US

load("output_data/raw_str_us.Rdata")
temp_str_us <- load_str(raw_str_us)

# these two data frames are the working data frames and become the outputs
str_us_m <- temp_str_us[[1]]
str_us_q <- temp_str_us[[2]]

# loads seasonal factors
load("output_data/str_us_m_factors.Rdata")
load("output_data/str_us_q_factors.Rdata")

# create monthly sa from seasonal factors using a function
str_us_m1 <- merge(str_us_m, str_us_m_factors, all=TRUE)
out_str_us_m <- create_sa_str_m(str_us_m1)

# create quarterly sa from seasonal factors using a function
str_us_q1 <- merge(str_us_q, str_us_q_factors, all=TRUE)
out_str_us_q <- create_sa_str_q(str_us_q1)

################
#
# creates a partial file with just the US and chainscale outputs, no metros
# 

print("preping US output files")
uslist<- c("ecous", "indus", "luxus", "midus", "upmus", "upsus", "upuus", "totus")

# monthly
out_str_us_m <- out_str_us_m %>% 
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # the following is a multiple negative look back
  # http://www.rexegg.com/regex-lookarounds.html
  separate(segvar, c("seg", "variable"), sep = "_(?!sf)(?!sa)") %>%
  # following filter is based on a list
  filter(seg %in% uslist) %>%
  mutate(variable = paste(seg, "_", variable, sep='')) %>%
  select(-seg) %>%
  spread(variable,value)

# quarterly
out_str_us_q <- out_str_us_q %>% 
  gather(segvar, value, -date, na.rm = FALSE) %>%
  separate(segvar, c("seg", "variable"), sep = "_(?!sf)(?!sa)") %>%
  filter(seg %in% uslist) %>%
  mutate(variable = paste(seg, "_", variable, sep='')) %>%
  select(-seg) %>%
  spread(variable,value)

# temp_out_uslist <- c("year", "month", "qtr", "days")

#########################################
#
# IHG Mexico

load("output_data/raw_str_ihg_mex.Rdata")
temp_str_ihg_mex <- load_str(raw_str_ihg_mex)

# these two data frames are the working data frames and become the outputs
str_ihg_mex_m <- temp_str_ihg_mex[[1]]
str_ihg_mex_q <- temp_str_ihg_mex[[2]]

# loads seasonal factors
load("output_data/str_ihg_mex_m_factors.Rdata")
load("output_data/str_ihg_mex_q_factors.Rdata")

# create monthly sa from seasonal factors using a function
str_ihg_mex_m1 <- merge(str_ihg_mex_m, str_ihg_mex_m_factors, all=TRUE)
out_str_ihg_mex_m <- create_sa_str_m(str_ihg_mex_m1)

# create quarterly sa from seasonal factors using a function
str_ihg_mex_q1 <- merge(str_ihg_mex_q, str_ihg_mex_q_factors, all=TRUE)
out_str_ihg_mex_q <- create_sa_str_q(str_ihg_mex_q1)

#########################
#
# writing outputs
#

# writes csv versions of the output files
write.zoo(out_str_us_m, file="output_data/out_str_us_m.csv", sep=",")
write.zoo(out_str_us_q, file="output_data/out_str_us_q.csv", sep=",")

write.zoo(out_str_ihg_mex_m, file="output_data/out_str_ihg_mex_m.csv", sep=",")
write.zoo(out_str_ihg_mex_q, file="output_data/out_str_ihg_mex_q.csv", sep=",")

# saves Rdata versions of the output files
save(out_str_us_m, file="output_data/out_str_us_m.Rdata")
save(out_str_us_q, file="output_data/out_str_us_q.Rdata")

save(out_str_ihg_mex_m, file="output_data/out_str_ihg_mex_m.Rdata")
save(out_str_ihg_mex_q, file="output_data/out_str_ihg_mex_q.Rdata")
