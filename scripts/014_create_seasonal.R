
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

dont_q_cols <- c("anaheim_supd|neworleans_supd|oahu_supd|sanfranchisco_supd|tampa_supd")


# creates seasonal factors and saves as Rdata files
# monthly
  str_us_m_factors <- seas_factors_m(str_us_m, dont_q_cols)
  save(str_us_m_factors, file="output_data/str_us_m_factors.Rdata")
  # quarterly
  str_us_q_factors <- seas_factors_q(str_us_q)
  save(str_us_q_factors, file="output_data/str_us_q_factors.Rdata")

###############
#
# IHG Mexico

load("output_data/raw_str_ihg_mex.Rdata")
temp_str_ihg_mex <- load_str(raw_str_ihg_mex)

# these two data frames are the working data frames and become the outputs
str_ihg_mex_m <- temp_str_ihg_mex[[1]]
str_ihg_mex_q <- temp_str_ihg_mex[[2]]

# creates seasonal factors and saves as Rdata files
# monthly
str_ihg_mex_m_factors <- seas_factors_m(str_ihg_mex_m)
save(str_ihg_mex_m_factors, file="output_data/str_ihg_mex_m_factors.Rdata")
# quarterly
str_ihg_mex_q_factors <- seas_factors_q(str_ihg_mex_q)
save(str_ihg_mex_q_factors, file="output_data/str_ihg_mex_q_factors.Rdata")

###############
#
# IHG Canada

load("output_data/raw_str_ihg_can.Rdata")
temp_str_ihg_can <- load_str(raw_str_ihg_can)

# these two data frames are the working data frames and become the outputs
str_ihg_can_m <- temp_str_ihg_can[[1]]
str_ihg_can_q <- temp_str_ihg_can[[2]]

# creates seasonal factors and saves as Rdata files
# monthly
str_ihg_can_m_factors <- seas_factors_m(str_ihg_can_m)
save(str_ihg_can_m_factors, file="output_data/str_ihg_can_m_factors.Rdata")
# quarterly
str_ihg_can_q_factors <- seas_factors_q(str_ihg_can_q)
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
                starts_with("upa"))

a <- c("upacal_adr|upacal_revpar|upacal_supd|upacho_supd|") 
b <- c("upalos_supd|upamxc_adr|upamxc_demd|upamxc_occ|upapho_adr|")
c <- c("upapho_supd|upaprt_demd|upasea_occ|upator_adr|upator_occ|")
d <- c("upator_supd|upavnc_adr|upavnc_demd|upavnc_occ|upavnc_supd|")
e <- c("upawas_adr")
dont_q_cols <- paste0(a, b, c, d, e)

dont_q_cols

# creates seasonal factors and saves as Rdata files
# monthly

# quarterly
# puts into several smaller data frames

a <- length(str_us_host_q)

str_us_host1_q <- str_us_host_q %>%
  select(date,1:100)
str_us_host1_q_factors <- seas_factors_q(str_us_host1_q, dont_q_cols)

str_us_host2_q <- str_us_host_q %>%
  select(date,101:a)
str_us_host2_q_factors <- seas_factors_q(str_us_host2_q, dont_q_cols)

str_us_host_q_factors <- left_join(
  str_us_host1_q_factors,
  str_us_host2_q_factors,
  by="date"
)
save(str_us_host_q_factors, file="output_data/str_us_host_q_factors.Rdata")




