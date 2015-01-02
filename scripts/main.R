
# my thinking is that functions file loads functions that should be available at 
# at any point. If I clear the workspace, I need to run fuctions again
# before running the next program

# I have a couple auxillary function files
# load_str just contains a function
# also seasonal_factors contains functions to create monthly and 
# quarterly seasonal factors

source("scripts/functions.R")

# reads the raw STR monthly files creates Rdata files
source("scripts/read_raw_str_us.R")
source("scripts/read_raw_str_ihg_mex.R")

# create monthly and quarterly seasonal factors, only run if necessary
source("scripts/create_seasonal.R")

# preps the STR data, including creating seasonal adjusted from factors
source("scripts/prep_str.R")

# as a result, four R data files saved (as well as csv versions) 
# # the first two include the metro data
# out_str_m out_str_q
# these second two are just US data
# out_str_m_us out_str_q_us

# reads STR opens and closes directly from Excel source file
source("scripts/load_str_openclose.R")
# as a result, two R files are saved (as well as csv versions)
# out_opcl_m
# out_opcl_q

# reads macro source file
knit("scripts/load_usmacro.Rmd")

# creates the ushist file
knit("scripts/create_ushist.Rmd")

# runs simple forecast 
source("scripts/simple_forecast.R")

# runs the markdown file
rmarkdown::render("scripts/us_overview_graphs.Rmd") #, output_dir = "/output_data/")



