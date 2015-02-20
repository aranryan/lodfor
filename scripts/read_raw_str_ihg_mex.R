
#######
#
# loads the STR data from IHG on Mexico upper midscale consistent reporting properties

#######
#
# name of files to read

# the history before 2008 came out of the IHG supermodel, then more recent
# history is from STR trend reports supplied by IHG

fname1 <- c("input_data/IHG Mexico upm consistent reporters - history from supermodel.xlsx")
fname2 <- c("input_data/IHG Mexico upm consistent reporters - 652401_UPPERMIDSCALECO_PESOS.xls")
fname3 <- c("input_data/IHG Mexico upm consistent reporters - 652398_UPPERMIDSCALECO_USD.xls")

########
#
# load STR data
#

temp1 <- read.xlsx(fname1, sheetName="Sheet1", startRow=1,colIndex =1:4,
                  header = TRUE)

# reads STR trend report in pesos
temp2 <- read.xlsx(fname2, sheetName="8) Raw Data", startRow=5,colIndex =2:18,
                   header = TRUE)
# dplyr chain that filters to drop rows where the YYYYM ends in 13
# or starts with TOTAL, and then also drops the NA row that appears at bottom
temp2b <- temp2 %>% filter(!grepl("STR", Date) &  !is.na(Date))  %>%
  # converts to numeric
  mutate(Supply=as.numeric(as.character(Supply)),
         Demand=as.numeric(as.character(Demand)),
         Revenue=as.numeric(as.character(Revenue))) %>%
  # pastes on 1 to be the day
  mutate(date=paste("1", Date, sep=" ")) %>%
  # converts to date using dmy from lubridate package
  mutate(date=dmy(date)) %>%
  # takes it out of POSIXlt format
  mutate(date=as.Date(date)) %>%
  select(date, upmmex_supt=Supply, upmmex_demt=Demand, upmmex_rmrevt=Revenue) 

# data in pesos, history before 2008 combined with history since 2008
raw_str_mex_pesos <- rbind(temp1, temp2b)

plot(raw_str_mex_pesos$upmmex_supt)
plot(raw_str_mex_pesos$upmmex_demt)
plot(raw_str_mex_pesos$upmmex_rmrevt)

# reads STR trend report in USD
temp3 <- read.xlsx(fname3, sheetName="8) Raw Data", startRow=5,colIndex =2:18,
                   header = TRUE)

# dplyr chain that filters to drop rows where the YYYYM ends in 13
# or starts with TOTAL, and then also drops the NA row that appears at bottom
raw_str_mex_usd <- temp3 %>% filter(!grepl("STR", Date) &  !is.na(Date))  %>%
  # converts to numeric
  mutate(Supply=as.numeric(as.character(Supply)),
         Demand=as.numeric(as.character(Demand)),
         Revenue=as.numeric(as.character(Revenue))) %>%
  # pastes on 1 to be the day
  mutate(date=paste("1", Date, sep=" ")) %>%
  # converts to date using dmy from lubridate package
  mutate(date=dmy(date)) %>%
  # takes it out of POSIXlt format
  mutate(date=as.Date(date)) %>%
    select(date, upmmexusd_supt=Supply, upmmexusd_demt=Demand, upmmexusd_rmrevt=Revenue) 

raw_str_ihg_mex <- merge(raw_str_mex_pesos, raw_str_mex_usd, all=TRUE)

plot(raw_str_ihg_mex$upmmexusd_supt)
plot(raw_str_ihg_mex$upmmexusd_demt)
plot(raw_str_ihg_mex$upmmexusd_rmrevt)
plot(raw_str_ihg_mex$upmmex_demt)

################
#
# does a quick filter on the data

# list of segments to keep
to_keep <- c("upmmex")
to_keep <- c(to_keep, "upmmexusd")

# puts into tidy format with a seg column that contains the segment code
# then filters to keep the segments
a1 <- raw_str_ihg_mex %>% 
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # separate on anything that is in not in the list of all characters and numbers
  separate(segvar, c("seg", "variable"), sep = "[^[:alnum:]]+") %>%
  # filters to keep segments in the list to_keep
  filter(seg %in% to_keep) %>%
  spread(variable,value) %>%
  melt(id=c("date","seg"), na.rm=FALSE) %>%
  mutate(variable = paste(seg, "_", variable, sep='')) %>%
  select(-seg) %>%
  dcast(date ~ variable)

raw_str_ihg_mex <- a1

# saves Rdata version of the data
save(raw_str_ihg_mex, file="output_data/raw_str_ihg_mex.Rdata")

