
########
#
# creates seasonal factors
# only necessary to run if updating seasonal factors
# 

# US and metros

# begins the same as the load_str step, using the load_str function
load("output_data/raw_str_us.Rdata")
temp_str_us <- load_str(raw_str_us)

# these two data frames are the working data frames
str_us_m <- temp_str_us[[1]]
str_us_q <- temp_str_us[[2]]

# creates seasonal factors and saves as Rdata files
# monthly
  str_us_m_factors <- seas_factors_m(str_us_m)
  save(str_us_m_factors, file="output_data/str_us_m_factors.Rdata")
  # quarterly
  str_us_q_factors <- seas_factors_q(str_us_q)
  save(str_us_q_factors, file="output_data/str_us_q_factors.Rdata")

# IHG mexico

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
