
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

  # for the metros, my temporary fix has been to separate them from the US/chains
# so it's just a copy of the prep_str_us file, but with a list of metros
# and with a couple of the files named "_metro" rather than "_us"
# it assumes you start right after running load_str, so before running, it's
# necessary to just run load_str again before running prep_str_metros
#
#
# - got stuck, wouldn't run seasonal adjustment of supply for anahiem, may need to try additive
# really need to try rewriting as a function
#

source("scripts/load_str.R")
source("scripts/prep_str_metro.R")

# as a result there will be two R data files saved (as well as csv versions) and the 
# work space gets cleaned up a bit


# create open close csv files by copying each sheet, deleting the first two rows
# then deleting rows at the bottom

source("load_str_openclose.R")



source("load_macro.R")

source("scripts/analyze.R")



#source("~/Project/R projects/lodging graphs/scripts/graphs.R")

