
# my thinking is that functions loads functions that should be available at 
# at any point. If I clear the workspace, I need to run fuctions again
# before running the next program

# as an improvement, I should try writting a seasonal adjustment function
# it would be my approach of taking a series, adjusting it, and then 
# the output would be an object with the various resulting series.
# maybe could have an argument that dictated whether it would be 
# additive or multiplicative. Might need to read about the "transform"
# spec.

# the prep_example.R file is there so that I have a way of working
# with an example series outside of the loop

source("scripts/functions.R")

# loads STR monthly and quarterly performance data
source("scripts/load_str.R")

# as a result of load_str, we have two objects lodus_m and lodus_q

# preps the STR data, including unit conversion of a couple series and seasonal adjustment
source("scripts/prep_str.R")

# as a result there will be two R data files saved (as well as csv versions) and the 
# work space gets cleaned up a bit


# reads opens and closes directly from Excel source file
source("load_str_openclose.R")


source("load_macro.R")

source("scripts/analyze.R")



#source("~/Project/R projects/lodging graphs/scripts/graphs.R")

