library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(seasonal, warn.conflicts=FALSE)

########
#
# creates seasonal factors
# only necessary to run if updating seasonal factors
# 


#########
#
# loads holiday regressors
#

load(file="~/Project/R projects/lodfor/output_data/holiday_regress.Rdata")
# unpack lists
a <- c(janend_list, val_list, mem_list, eas_list, jlf_list, augend_list, sepstr_list, 
       hlw_list, vet_list, thk_list, chr_list, han_list)
varNames <- names(a)
for (i in seq_along(varNames)) {
  print(varNames[i])
  hold_a <- a[[i]]
  # names the vector, this uses the first object as a name for the second object
  assign(paste(varNames[i], sep=""), hold_a)
}

hold_reg <- cbind(eas_7_1_ts_m, val_fs_ts_m, augend_ss_ts_m,
                  sepstr_ss_ts_m, sepstr_mon_ts_m, mempost_m, jlf_fssm_ts_m, hlw_fss_ts_m,
                  thk_2826_ts_m, chr_fri_ts_m, hanwdayschr_m)



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
# modified this monthly piece to use seas_factors_m_2, which is a slightly modified version of 
# seas_factors_m, it uses the holiday regressors as an input.
str_us_m_factors <- seas_factors_m_2(str_m, dont_m_cols=dont_q_cols, hold_reg=hold_reg)
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
                starts_with("tot"))



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

# approach to do just selected markets. I added this so I could run the additional markets 
# without overwriting the factors for the existing markets. 
str_us_host_select_q <- str_us_host_q %>%
  select(date,matches('oklca'))
str_us_host_select_q_factors <- seas_factors_q(str_us_host_select_q, dont_q_cols)


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
 save(str_us_host_select_q_factors, file="output_data/str_us_host_select_q_factors.Rdata")




