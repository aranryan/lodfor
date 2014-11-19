
# my thinking is that functions loads functions that should be available at 
# at any point. If I clear the workspace, I need to run fuctions again
# before running the next program
source("scripts/functions.R")

# loads STR monthly and quarterly performance data
source("scripts/load_str.R")
# as a result, we have two objects in the workspace (lodus_m and lodus_q)

# preps the STR data, including unit conversion of a couple series and seasonal adjustment
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



