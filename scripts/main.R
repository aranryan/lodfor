
# functions file loads functions that should be available at 
# at any point. If I clear the workspace, I need to run fuctions again
# before running the next program

# I have a couple auxillary function files
# load_str just contains a function
# also seasonal_factors contains functions to create monthly and 
# quarterly seasonal factors
source("scripts/setup.R")
source("scripts/functions.R")

# read raw STR monthly files
# results saved in Rdata file (dataframe)
source("scripts/read_raw_str_us.R")
source("scripts/read_raw_str_ihg_mex.R")
source("scripts/read_raw_str_ihg_can.R")
source("scripts/read_raw_str_us_host.R")

# create monthl and quarterly seasonal factors, only run if necessary
# results saved in Rdata files (dataframe)
#source("scripts/create_seasonal.R")

# preps the STR data, including creating seasonal adjusted from factors
# results saved in Rdata (xts) and csv files 
source("scripts/prep_str.R")
source("scripts/prep_str_host.R")

# reads STR opens and closes directly from Excel source file
# results saved in Rdata (xts) and csv files
source("scripts/load_str_openclose.R")

# reads macro source file
# results saved in Rdata (xts) and csv files

rmarkdown::render('scripts/load_usmacro.Rmd') #, output_dir = './output_data')


#knit("scripts/load_usmacro.Rmd")

# creates the ushist file
# I have to do this manually by stepping through each chunk because
# right now it won't save the output file if I just
# unit it using knit. I'm not sure why not. Could search
# for examples of people maintaining code in Rmd format
# maybe they don't
knit("scripts/create_ushist.Rmd")

# runs simple forecast 
source("scripts/simple_forecast.R")

# reads in the current forecast 
source("scripts/read_usfor.R")

# creates a Rdata file with Fred data used in graphs
source("scripts/pull_fred_data.R")

# compiles some groups of top 25 markets
source("scripts/compile_top25.R")

# runs the markdown file
rmarkdown::render("scripts/us_overview_graphs.Rmd") #, output_dir = "/output_data/")

# creates an eviews output for host analysis
source("scripts/out_to_eviews.R")

