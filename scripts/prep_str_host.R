


#########################################
#
# Host market data

load("output_data/raw_str_us_host.Rdata")
temp_str_us_host <- load_str(raw_str_us_host)

# these two data frames are the working data frames and become the outputs
str_us_host_m <- temp_str_us_host[[1]]
str_us_host_q <- temp_str_us_host[[2]]

# loads seasonal factors
load("output_data/str_us_host_m_factors.Rdata")
load("output_data/str_us_host_q_factors.Rdata")

# create monthly sa from seasonal factors using a function
str(str_us_host_m)
str(str_us_host_m_factors)
str_us_host_m1 <- merge(str_us_host_m, str_us_host_m_factors, all=TRUE, by="date")
out_str_us_host_m <- str_us_host_m1 %>%
  create_sa_str_m() %>%
  read.zoo() %>%
  xts()

# create quarterly sa from seasonal factors using a function
str_us_host_q1 <- merge(str_us_host_q, str_us_host_q_factors, all=TRUE)
out_str_us_host_q <- str_us_host_q1 %>%
  create_sa_str_q() %>%
  read.zoo() %>%
  xts()

# a <- out_str_us_host_q %>%
#   data.frame(date=time(.), .) %>%
#   select(date, contains("upsus"))
#  

# a <- out_str_us_host_q %>%
#   data.frame(date=time(.), .) %>%
#   select(date, contains("upsmia"))
# plot(a$upsmia_adr_sa, type="l")
#########################
#
# writing outputs
#

# writes csv versions of the output files
write.zoo(out_str_us_host_m, file="output_data/out_str_us_host_m.csv", sep=",")
write.zoo(out_str_us_host_q, file="output_data/out_str_us_host_q.csv", sep=",")

# saves Rdata versions of the output files
save(out_str_us_host_m, file="output_data/out_str_us_host_m.Rdata")
save(out_str_us_host_q, file="output_data/out_str_us_host_q.Rdata")
