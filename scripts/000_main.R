
# functions file loads functions that should be available at 
# at any point. If I clear the workspace, I need to run fuctions again
# before running the next program

# I have a couple auxillary function files
# load_str just contains a function
# also seasonal_factors contains functions to create monthly and 
# quarterly seasonal factors

#source("scripts/setup.R")
#source("scripts/functions.R")
#source("scripts/functions_combined.R")

# read raw STR monthly files
# results saved in Rdata file (dataframe)
source("scripts/010_read_raw_str_us.R")
source("scripts/011_read_raw_str_ihg_mex.R")
source("scripts/012_read_raw_str_ihg_can.R")
rmarkdown::render("scripts/013_read_raw_str_us_host.Rmd") 

# create monthly and quarterly seasonal factors, only run if necessary
# results saved in Rdata files (dataframe)
#source("scripts/014_create_seasonal.R")

# preps the STR data, including creating seasonal adjusted from factors
# results saved in Rdata (xts) and csv files 
source("scripts/020_prep_str.R")
source("scripts/021_prep_str_host.R")

# reads STR opens and closes directly from Excel source file
# results saved in Rdata (xts) and csv files
source("scripts/030_load_str_openclose.R")

# reads macro source file
# results saved in Rdata (xts) and csv files
rmarkdown::render('scripts/040_load_usmacro.Rmd')

# creates the ushist file
rmarkdown::render('scripts/050_create_ushist.Rmd')
rmarkdown::render('scripts/051_create_ushist_host.Rmd')

# runs simple forecast 
#source("scripts/060_simple_forecast.R")

# reads in the current forecast 
source("scripts/070_read_usfor.R")

# creates a Rdata file with Fred data used in graphs
source("scripts/080_pull_fred_data.R")

# compiles some groups of top 25 markets
source("scripts/090_compile_top25.R")

# runs the markdown file
rmarkdown::render("scripts/100_us_overview_graphs.Rmd") 

# run several experiements with graph resolution
source("scripts/101_graph_resolution_test.R")

# creates an eviews output for host analysis
source("scripts/110_out_to_eviews.R")
source("scripts/120_build_lodhstbk.R")

# creates a file with ttm STR data and other monthly data
# initially created to population Blackstone demand monitor
rmarkdown::render("scripts/125_build_m_ttm.Rmd")

# seasonal adjustment discussion files
rmarkdown::render("scripts/202_exp_seasonal_short.Rmd") 
rmarkdown::render("scripts/203_exp_seasonal_intro.Rmd")
rmarkdown::render("scripts/204_exp_seasonal_intro-upm.Rmd")
rmarkdown::render("scripts/205_exp_seasonal_demo.Rmd")
rmarkdown::render("scripts/206_exp_seasonal_compare.Rmd")
rmarkdown::render("scripts/207_exp_seasonal_examples.Rmd")

# working on a more complete seasonal adjustment process

# this creates outputs with holiday dates
rmarkdown::render("scripts/210_seasonal_create_dates.Rmd")
# this creates actual seasonal regressors
rmarkdown::render("scripts/211_seasonal_create_regressors.Rmd")
# this is a discussion document I used with IHG on March 15, 2016
rmarkdown::render("scripts/220_sea_model_work.Rmd")
# taking the analysis further
rmarkdown::render("scripts/221_sea_model_work.Rmd")


