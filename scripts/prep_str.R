
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

#####################
#
# adds str_days to the monthly and quarterly objects

# add a str_days series with the number of days in each month and quarter
# there are already series such as totus_days, but they don't go into 
# the future
b_m <- as.data.frame(out_str_us_m$date )
colnames(b_m) <- c("date")
b_m <- b_m %>% 
   transform(totus_strdays = sapply(date, days_in_month,leap_impact=0)) %>%
  read.zoo(drop=FALSE) 

# for quarterly, we need to to extend to the end of the quarterly series
# so summing the monthly dataframe doesn't work. But then the days_in_month
# function isn't giving a quarterly answer just days in the first month
# of the quarter. So solution was to create a monthly series that extended
# the full length, and then sum that.

# creates newm as a monthly zoo object with number of days for ful
# length of quarterly
temp <- read.zoo(out_str_us_q)
starta <- start(temp)
enda <- end(temp)
rm(temp)
newm <- zoo(1,seq(starta,enda,by="month"))
newma <- index(newm)
newm_df<- as.data.frame(newm)
newm_df$date <- rownames(newm_df)
newm_df <- newm_df %>%
   transform(totus_strdays = sapply(date, days_in_month,leap_impact=0)) %>%
   select(-newm)
newm <- read.zoo(newm_df, drop=FALSE) 
#sums zoo object to quarterly
start <- as.yearqtr((start(newm)))
b_q <- zooreg(vapply(newm, m_to_q, FUN.VALUE = 
                       numeric(ceiling(nrow(newm)/3)), 
                     type="sum"), start=start, frequency=4)

b_m <- as.data.frame(b_m)
b_m <- cbind(date = rownames(b_m), b_m)
b_m$date <- as.Date(b_m$date)

b_q <- data.frame(date=time(b_q), b_q) 
b_q$date <- as.Date(b_q$date)
row.names(b_q) <- NULL

out_str_us_m <- merge(out_str_us_m, b_m)
out_str_us_q <- merge(out_str_us_q, b_q)

################
#
# creates a full file with us segments and us metros
# 

out_str_us_m <- out_str_us_m %>%
  read.zoo() %>%
  xts()
  
out_str_us_q <- out_str_us_q %>%
  read.zoo() %>%
  xts()

################
#
# creates a partial file with just the US and chainscale outputs, no metros
# 
# 
# print("preping US output files")
# uslist<- c("ecous", "indus", "luxus", "midus", "upmus", "upsus", "upuus", "totus")
# 
# # monthly
# out_str_us_m <- out_str_us_m %>% 
#   gather(segvar, value, -date, na.rm = FALSE) %>%
#   # the following is a multiple negative look back
#   # http://www.rexegg.com/regex-lookarounds.html
#   separate(segvar, c("seg", "variable"), sep = "_(?!sf)(?!sa)") %>%
#   # following filter is based on a list
#   filter(seg %in% uslist) %>%
#   mutate(variable = paste(seg, "_", variable, sep='')) %>%
#   select(-seg) %>%
#   spread(variable,value) %>%
#   read.zoo() %>%
#   xts()
# 
# # quarterly
# out_str_us_q <- out_str_us_q %>% 
#   gather(segvar, value, -date, na.rm = FALSE) %>%
#   separate(segvar, c("seg", "variable"), sep = "_(?!sf)(?!sa)") %>%
#   filter(seg %in% uslist) %>%
#   mutate(variable = paste(seg, "_", variable, sep='')) %>%
#   select(-seg) %>%
#   spread(variable,value) %>%
#   read.zoo() %>%
#   xts()
# 
# # temp_out_uslist <- c("year", "month", "qtr", "days")

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
out_str_ihg_mex_m <- str_ihg_mex_m1 %>%
  create_sa_str_m() %>%
  read.zoo() %>%
  xts()

# create quarterly sa from seasonal factors using a function
str_ihg_mex_q1 <- merge(str_ihg_mex_q, str_ihg_mex_q_factors, all=TRUE)
out_str_ihg_mex_q <- str_ihg_mex_q1 %>%
  create_sa_str_q() %>%
  read.zoo() %>%
  xts()

#########################################
#
# IHG Canada

load("output_data/raw_str_ihg_can.Rdata")
temp_str_ihg_can <- load_str(raw_str_ihg_can)

# these two data frames are the working data frames and become the outputs
str_ihg_can_m <- temp_str_ihg_can[[1]]
str_ihg_can_q <- temp_str_ihg_can[[2]]

# loads seasonal factors
load("output_data/str_ihg_can_m_factors.Rdata")
load("output_data/str_ihg_can_q_factors.Rdata")

# create monthly sa from seasonal factors using a function
str(str_ihg_can_m)
str(str_ihg_can_m_factors)
str_ihg_can_m1 <- merge(str_ihg_can_m, str_ihg_can_m_factors, all=TRUE, by="date")
out_str_ihg_can_m <- str_ihg_can_m1 %>%
  create_sa_str_m() %>%
  read.zoo() %>%
  xts()

# create quarterly sa from seasonal factors using a function
str_ihg_can_q1 <- merge(str_ihg_can_q, str_ihg_can_q_factors, all=TRUE)
out_str_ihg_can_q <- str_ihg_can_q1 %>%
  create_sa_str_q() %>%
  read.zoo() %>%
  xts()

#########################
#
# writing outputs
#

# writes csv versions of the output files
write.zoo(out_str_us_m, file="output_data/out_str_us_m.csv", sep=",")
write.zoo(out_str_us_q, file="output_data/out_str_us_q.csv", sep=",")

write.zoo(out_str_ihg_mex_m, file="output_data/out_str_ihg_mex_m.csv", sep=",")
write.zoo(out_str_ihg_mex_q, file="output_data/out_str_ihg_mex_q.csv", sep=",")

write.zoo(out_str_ihg_can_m, file="output_data/out_str_ihg_can_m.csv", sep=",")
write.zoo(out_str_ihg_can_q, file="output_data/out_str_ihg_can_q.csv", sep=",")

# saves Rdata versions of the output files
save(out_str_us_m, file="output_data/out_str_us_m.Rdata")
save(out_str_us_q, file="output_data/out_str_us_q.Rdata")

save(out_str_ihg_mex_m, file="output_data/out_str_ihg_mex_m.Rdata")
save(out_str_ihg_mex_q, file="output_data/out_str_ihg_mex_q.Rdata")

save(out_str_ihg_can_m, file="output_data/out_str_ihg_can_m.Rdata")
save(out_str_ihg_can_q, file="output_data/out_str_ihg_can_q.Rdata")

