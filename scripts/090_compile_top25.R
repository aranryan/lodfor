
# creates a top 25 compilation file that has quarterly demand and supply 
# calculated for various groups of markets. Not indexed.

library(arlodr, warn.conflicts=FALSE)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(seasonal, warn.conflicts=FALSE)
Sys.setenv(X13_PATH = "C:/Aran Installed/x13ashtml")

fpath <- c("~/Project/R projects/lodfor/")
load(paste(fpath, "output_data/ushist_q.Rdata", sep=""))

# puts the quarterly ushist into a melted data frame
ushist_q_m <- ushist_q %>%
  window(end = as.Date("2015-10-01")) %>%
  data.frame(date=index(.), .) %>%
  gather(variable, value, -date)
  #reshape2::melt(id.vars = c("date"))

# create dataframe with sums of selected markets
# could be done as a function for a given list of metros
# but I was lazy, so just groups of commands
# run multiple times

# create list of top25
templist <- c("anaheim", "atlanta", "boston", "chicago", 
              "dallas", "denver", "detroit", "houston", 
              "lalongbeach",  "miami", "minneapolis",  "nashville",
              "neworleans", "newyork", "norfolk", "oahu", 
              "orlando", "philadelphia", "phoenix", "sandiego", 
              "sanfrancisco", "seattle", "stlouis", "tampa", 
              "washingtondc")

col_list <- unique (grep(paste(templist,collapse="|"), colnames(ushist_q), value=TRUE)) %>%
  grep('_demd_sa|_supd_sa|_demd|_demt|_supd|_supt|_rmrevd|_rmrevt', ., value=TRUE)

temp <- ushist_q_m %>%
  filter(variable %in% col_list) %>%
  # I had difficulty separating by the underscore
  # because there are more than one underscore in some
  # so my solution was to mutate the column, applying 
  # the sub function, which replaces the first occurance of
  # the underscore with a period
  mutate(segvar = sub("_",".", variable)) %>%
  select(-variable) %>%
  # then run the separate on the period, using backslashes
  # to escape out of the second character
  separate(segvar, c("seg", "variable"), sep = "\\.") %>%
  group_by(date, variable) %>%
  summarize(value_sum=sum(value)) %>%
  ungroup() %>%
  spread(variable, value_sum) %>%
  na.omit() %>%
  as.data.frame()
cna <- colnames(temp)
colnames(temp) <- paste("top25us", cna, sep="_") # change name here
temp_top25us <- temp %>% # change name here
  read.zoo() %>%
  xts()

# create list of topcoast
templist <- c("newyork", "lalongbeach", "washingtondc", "anaheim", 
              "boston", "miami", "philadelphia", "sandiego", "sanfrancisco", "seattle")
col_list <- unique (grep(paste(templist,collapse="|"), colnames(ushist_q), value=TRUE)) %>%
  grep('_demd_sa|_supd_sa|_demd|_demt|_supd|_supt|_rmrevd|_rmrevt', ., value=TRUE)
temp <- ushist_q_m %>%
  filter(variable %in% col_list) %>%
  # I had difficulty separating by the underscore
  # because there are more than one underscore in some
  # so my solution was to mutate the column, applying 
  # the sub function, which replaces the first occurance of
  # the underscore with a period
  mutate(segvar = sub("_",".", variable)) %>%
  select(-variable) %>%
  # then run the separate on the period, using backslashes
  # to escape out of the second character
  separate(segvar, c("seg", "variable"), sep = "\\.") %>%
  group_by(date, variable) %>%
  summarize(value_sum=sum(value)) %>%
  ungroup() %>%
  spread(variable, value_sum) %>%
  na.omit() %>%
  as.data.frame()
cna <- colnames(temp)
colnames(temp) <- paste("topcoast", cna, sep="_") # change name here
temp_topcoast <- temp %>% # change name here
  read.zoo() %>%
  xts()




# create list of topcoastwony
templist <- c("lalongbeach", "washingtondc", "anaheim", 
              "boston", "miami", "philadelphia", "sandiego", "sanfrancisco", "seattle")
col_list <- unique (grep(paste(templist,collapse="|"), colnames(ushist_q), value=TRUE)) %>%
  grep('_demd_sa|_supd_sa|_demd|_demt|_supd|_supt|_rmrevd|_rmrevt', ., value=TRUE)
temp <- ushist_q_m %>%
  filter(variable %in% col_list) %>%
  # I had difficulty separating by the underscore
  # because there are more than one underscore in some
  # so my solution was to mutate the column, applying 
  # the sub function, which replaces the first occurance of
  # the underscore with a period
  mutate(segvar = sub("_",".", variable)) %>%
  select(-variable) %>%
  # then run the separate on the period, using backslashes
  # to escape out of the second character
  separate(segvar, c("seg", "variable"), sep = "\\.") %>%
  group_by(date, variable) %>%
  summarize(value_sum=sum(value)) %>%
  ungroup() %>%
  spread(variable, value_sum) %>%
  na.omit() %>%
  as.data.frame()
cna <- colnames(temp)
colnames(temp) <- paste("topcoastwony", cna, sep="_") # change name here
temp_topcoastwony <- temp %>% # change name here
  read.zoo() %>%
  xts()




# create list of topcoastwonydc
templist <- c("lalongbeach", "anaheim", 
              "boston", "miami", "philadelphia", "sandiego", "sanfrancisco", "seattle")
col_list <- unique (grep(paste(templist,collapse="|"), colnames(ushist_q), value=TRUE)) %>%
  grep('_demd_sa|_supd_sa|_demd|_demt|_supd|_supt|_rmrevd|_rmrevt', ., value=TRUE)
temp <- ushist_q_m %>%
  filter(variable %in% col_list) %>%
  # I had difficulty separating by the underscore
  # because there are more than one underscore in some
  # so my solution was to mutate the column, applying 
  # the sub function, which replaces the first occurance of
  # the underscore with a period
  mutate(segvar = sub("_",".", variable)) %>%
  select(-variable) %>%
  # then run the separate on the period, using backslashes
  # to escape out of the second character
  separate(segvar, c("seg", "variable"), sep = "\\.") %>%
  group_by(date, variable) %>%
  summarize(value_sum=sum(value)) %>%
  ungroup() %>%
  spread(variable, value_sum) %>%
  na.omit() %>%
  as.data.frame()
cna <- colnames(temp)
colnames(temp) <- paste("topcoastwonydc", cna, sep="_") # change name here
temp_topcoastwonydc <- temp %>% # change name here
  read.zoo() %>%
  xts()




# create list of cawawosf
templist <- c("anaheim",  
              "lalongbeach",  "sandiego", 
              "sanfrancisco", "seattle")
col_list <- unique (grep(paste(templist,collapse="|"), colnames(ushist_q), value=TRUE)) %>%
  grep('_demd_sa|_supd_sa|_demd|_demt|_supd|_supt|_rmrevd|_rmrevt', ., value=TRUE)
temp <- ushist_q_m %>%
  filter(variable %in% col_list) %>%
  # I had difficulty separating by the underscore
  # because there are more than one underscore in some
  # so my solution was to mutate the column, applying 
  # the sub function, which replaces the first occurance of
  # the underscore with a period
  mutate(segvar = sub("_",".", variable)) %>%
  select(-variable) %>%
  # then run the separate on the period, using backslashes
  # to escape out of the second character
  separate(segvar, c("seg", "variable"), sep = "\\.") %>%
  group_by(date, variable) %>%
  summarize(value_sum=sum(value)) %>%
  ungroup() %>%
  spread(variable, value_sum) %>%
  na.omit() %>%
  as.data.frame()
cna <- colnames(temp)
colnames(temp) <- paste("cawawosf", cna, sep="_") # change name here
temp_cawawosf <- temp %>% # change name here
  read.zoo() %>%
  xts()

################################
#
# combines
#

top25_sets <- merge(temp_top25us, temp_topcoast, temp_topcoastwony, 
                      temp_topcoastwonydc, temp_cawawosf) %>%
  data.frame(date=time(.), .) 

################################
#
# creates seasonally adjusted ADR, occupancy and RevPAR for all groups in the 
# dataframe

# works by first adding unadjusted ADR, occ and RevPAR to the full dataframe
temp1 <- top25_sets %>%
  gather(variable, value, -date) %>%
 # melt(id.vars = c("date")) %>%
  separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
  # drop anything that is already seasonally adjusted, because it is the sum of various
  # adjusted series, which I'm not using in this current setup
  filter(., !grepl("_s", var)) %>%
  spread(var, value) %>%
  mutate(occ = demt / supt) %>%
  mutate(adr = rmrevt / demt) %>%
  mutate(revpar = rmrevt / supt)

 
# selects what is to be seasonally adjusted
temp_selected <- temp1 %>%
  select(date, seg, demd, supd, occ, adr, revpar) %>%
  gather(var, value, demd:revpar) %>%
  mutate(segvar = paste(seg,var, sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)


# selects what isn't going to be adjusted but is still useful
temp_nonadj <- temp1 %>%
  select(date, seg, demt, supt, rmrevt) %>%
  gather(var, value, demt:rmrevt) %>%
  mutate(segvar = paste(seg,var, sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value) %>%
  as.data.frame() %>%
  read.zoo() %>%
  xts()

# creates seasonal factors 

selected_factors <- seas_factors_q(temp_selected, dont_q_cols=c("blank"))

# create quarterly sa from seasonal factors
temp_selected2 <- merge(temp_selected, selected_factors, all=TRUE)

# follows the create_sa_str_q function in my functions script, 
# but since this isn't doing all the same series I had to modify it
# following converts to a tidy format, uses seasonal factors to calculate sa
# series, then converts back to a wide dataframe
out_temp_1 <- temp_selected2 %>% 
  # creates column called segvar that contains the column names, and one next to 
  # it with the values, dropping the time column
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # in the following the ^ means anything not in the list
  # with the list being all characters and numbers
  # so it separates segvar into two colums using sep
  # it separates on the _, as long as it's not followed by sf
  # the not followed piece uses a Negative Lookahead from
  # http://www.regular-expressions.info/lookaround.html
  separate(segvar, c("seg", "variable"), sep = "_(?!sf)") %>%
  # keeps seg as a column and spreads variable into multiple columns containing
  # the values
  spread(variable,value) %>%
  mutate(occ_sa = occ / occ_sf) %>%
  mutate(revpar_sa = revpar / revpar_sf) %>%
  mutate(adr_sa = adr / adr_sf) %>%
  mutate(demd_sa = demd / demd_sf) %>%
  mutate(supd_sa = supd / supd_sf) %>%
  # puts it back into a wide data frame, with one column for each series
  # days is a series for each segment/market\
  gather(variable, value, -date, -seg) %>%
  #reshape2::melt(id=c("date","seg"), na.rm=FALSE) %>%
  mutate(variable = paste(seg, "_", variable, sep='')) %>%
  select(-seg) %>%
  spread(variable,value) %>%
  as.data.frame() %>%
  read.zoo() %>%
  xts()



######################
#
# converts some series to real
#


# takes the personal cons price deflator index from ushist_q
# just 1987 forward
us_pc_index <- ushist_q$us_pc_index["1987-01-01/"] 

# to get us_pc_index and out_temp to have the same length 
# merged them together. That way when it does the conversion to 
# real below they both have the same length. In  other words, 
# this extends out_temp with NAs, but then it's using the 
# us_pc_index as a separate object anyway
out_temp_2 <- merge(out_temp_1, us_pc_index)

# select the series that contain adr or revpar and convert to real
# the way this works is that matches works on a regular expression
# I wrote a regular expression that is taking _adr_ or _revpar_
# for reference on writing regular expressions, see
# http://www.regular-expressions.info/quickstart.html
real_df <- data.frame(out_temp_2) %>%
  select(matches("_adr$|_adr_sa|_revpar$|_revpar_sa")) %>%
  mutate_each(funs(ind = ( . / us_pc_index)*100))
# adds on a time index to get it back to xts
temp <- data.frame(date=time(out_temp_2)) 
real_df <- cbind(temp,real_df)
real <- read.zoo(real_df)
real <- xts(real)

# renames series 
tempnames <- names(real)
tempnames <- paste(tempnames,"rpc",sep="")
tempnames
names(real) <- tempnames
rm(tempnames)

out_temp_3 <- merge(out_temp_2, real)

#######################
#
# adds US series

us_list <- c("totus_demt", "totus_demd", "totus_demd_sa", "totus_supd", 
             "totus_supd_sa", "totus_supt", 
             "totus_rmrevt", "totus_occ", "totus_occ_sa", "totus_adr_sa", 
             "totus_adr", "totus_revpar", "totus_revpar_sa", 
             "totus_adr_sarpc", "totus_revpar_sarpc")
temp_totus <- ushist_q_m %>%
  filter(variable %in% us_list) %>%
  na.omit() %>%
  spread(variable, value) %>%
  as.data.frame() %>%
  read.zoo() %>%
  xts()

top25compile <- merge(temp_nonadj, out_temp_3, temp_totus) %>%
  data.frame(date=time(.), .) 

# puts columns in alphabetical order
top25compile <- top25compile[,order(names(top25compile))] %>%
# puts date back at the beginning
  select(date, everything()) 

#####################

# saves Rdata versions of the output files
save(top25compile, file=paste(fpath, "output_data/top25compile.Rdata", sep=""))

# writes csv versions of the output files
write.csv(top25compile, file="output_data/top25compile.csv", row.names=FALSE)

