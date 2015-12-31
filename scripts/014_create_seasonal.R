library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(seasonal, warn.conflicts=FALSE)
Sys.setenv(X13_PATH = "C:/Aran Installed/x13ashtml")

########
#
# creates seasonal factors
# only necessary to run if updating seasonal factors
# 

###############
#
# US and top 25 metros

# begins the same as the load_str step, using the load_str function
load("output_data/raw_str_us.Rdata")
temp_str_us <- load_str(raw_str_us)

# these two data frames are the working data frames
str_us_m <- temp_str_us[[1]]
str_us_q <- temp_str_us[[2]]

# drops series that aren't going to be adjusted
  str_m <- select(str_us_m, 
                    -ends_with("_days"), 
                    -ends_with("_demt"), 
                    -ends_with("_rmrevt"), 
                    -ends_with("_supt"))

  str_q <- select(str_us_q, 
                    -ends_with("_days"), 
                    -ends_with("_demt"), 
                    -ends_with("_rmrevt"), 
                    -ends_with("_supt"))

# why isn't there a dont_m_cols list?
dont_q_cols <- c("anaheim_supd|neworleans_supd|oahu_supd|sanfrancisco_supd|tampa_supd")


# creates seasonal factors and saves as Rdata files
# monthly
  str_us_m_factors <- seas_factors_m(str_m, dont_q_cols)
  save(str_us_m_factors, file="output_data/str_us_m_factors.Rdata")
  # quarterly
  str_us_q_factors <- seas_factors_q(str_q, dont_q_cols)
  save(str_us_q_factors, file="output_data/str_us_q_factors.Rdata")

###############
#
# IHG Mexico

dont_m_cols <- c("blank")
dont_q_cols <- c("blank")
  
load("output_data/raw_str_ihg_mex.Rdata")
temp_str_ihg_mex <- load_str(raw_str_ihg_mex)

# these two data frames are the working data frames and become the outputs
str_ihg_mex_m <- temp_str_ihg_mex[[1]]
str_ihg_mex_q <- temp_str_ihg_mex[[2]]

# drops series that aren't going to be adjusted
str_m <- select(str_ihg_mex_m, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

str_q <- select(str_ihg_mex_q, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

# creates seasonal factors and saves as Rdata files
# monthly
str_ihg_mex_m_factors <- seas_factors_m(str_m, dont_m_cols)
save(str_ihg_mex_m_factors, file="output_data/str_ihg_mex_m_factors.Rdata")
# quarterly
str_ihg_mex_q_factors <- seas_factors_q(str_q, dont_q_cols)
save(str_ihg_mex_q_factors, file="output_data/str_ihg_mex_q_factors.Rdata")

###############
#
# IHG Canada

dont_m_cols <- c("blank")
dont_q_cols <- c("blank")

load("output_data/raw_str_ihg_can.Rdata")
temp_str_ihg_can <- load_str(raw_str_ihg_can)

# these two data frames are the working data frames and become the outputs
str_ihg_can_m <- temp_str_ihg_can[[1]]
str_ihg_can_q <- temp_str_ihg_can[[2]]

# drops series that aren't going to be adjusted
str_m <- select(str_ihg_can_m, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

str_q <- select(str_ihg_can_q, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

# creates seasonal factors and saves as Rdata files
# monthly
str_ihg_can_m_factors <- seas_factors_m(str_m, dont_m_cols)
save(str_ihg_can_m_factors, file="output_data/str_ihg_can_m_factors.Rdata")
# quarterly
str_ihg_can_q_factors <- seas_factors_q(str_q, dont_q_cols)
save(str_ihg_can_q_factors, file="output_data/str_ihg_can_q_factors.Rdata")

###############
#
# Host US
load("output_data/raw_str_us_host.Rdata")
temp_str_us_host <- load_str(raw_str_us_host)

# these two data frames are the working data frames and become the outputs
str_us_host_m <- temp_str_us_host[[1]]
str_us_host_q <- temp_str_us_host[[2]]


# drops series that aren't going to be adjusted
str_us_host_m <- select(str_us_host_m, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

str_us_host_q <- select(str_us_host_q, 
                -ends_with("_days"), 
                -ends_with("_demt"), 
                -ends_with("_rmrevt"), 
                -ends_with("_supt"))

# to start with, let's just do upa
str_us_host_q <- select(str_us_host_q, 
                date, 
                starts_with("upa"), 
                starts_with("totus"))

a <- c("upa_calcn_can_supd|upa_mmptn_usa_supd|upa_mxcmx_mex_supd|") 
b <- c("upa_slcut_usa_supd|upa_sttwa_usa_supd|upa_torcn_can_supd|")
c <- c("upa_vnccn_can_supd")
dont_q_cols <- paste0(a, b, c)

# creates seasonal factors and saves as Rdata files
# monthly

# quarterly
# puts into several smaller data frames
str_us_host1_q <- str_us_host_q %>%
  select(date,1:50)
str_us_host1_q_factors <- seas_factors_q(str_us_host1_q, dont_q_cols)

str_us_host2_q <- str_us_host_q %>%
  select(date,51:100)
str_us_host2_q_factors <- seas_factors_q(str_us_host2_q, dont_q_cols)

str_us_host3_q <- str_us_host_q %>%
  select(date,101:150)
str_us_host3_q_factors <- seas_factors_q(str_us_host3_q, dont_q_cols)

str_us_host4_q <- str_us_host_q %>%
  select(date,151:length(str_us_host_q))
str_us_host4_q_factors <- seas_factors_q(str_us_host4_q, dont_q_cols)

# joins them together
str_us_host_q_factors <- left_join(
  str_us_host1_q_factors,
  str_us_host2_q_factors,
  by="date"
)

str_us_host_q_factors <- left_join(
  str_us_host_q_factors,
  str_us_host3_q_factors,
  by="date"
)

str_us_host_q_factors <- left_join(
  str_us_host_q_factors,
  str_us_host4_q_factors,
  by="date"
)

save(str_us_host_q_factors, file="output_data/str_us_host_q_factors.Rdata")




