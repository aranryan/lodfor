


# reference file to use in converting market names to shorter abbreviations
colc <- c(rep("character",4))
host_str_simp <- read.csv("reference/host_str_simp.csv", header = TRUE, sep = ",", colClasses=colc)

#######
#
# name of file to read

fname <- c("input_data/Host - top 20 - ByMarket - 2015-07-27.csv")

########
#
# load STR data
#

# first read in the first two rows after skipping 7, and grab the names of the markets and 
# segments from the first row
first1 <- read.csv(fname, header = FALSE, sep = ",", 
                   nrows=1, stringsAsFactors=FALSE, na.strings=c("", "NA"), skip=7)
# row1 is used later as the column names for the data
row1 <- first1 %>%
  select(V1,V2, num_range("V",5:ncol(.))) %>%
  as.character()
row1[1] <- c("seg_text")
row1[2] <- c("geo_text")
row1[3] <- c("var")
row1 <- str_replace(row1,"/","-")
# earlier version in which row1 was a data frame
#row1 <- lapply(row1[1,], function(x) str_replace(x,"/","-"))
a <- as.character(row1[4:length(row1)]) %>%
  str_replace("/","-") %>%
  as.yearmon(., "%Y-%B") %>%
  as.Date() %>%
  as.character()
row1[4:length(row1)] <- a
head(row1)


#######################
#
# now read in the table without headers

# in the following, made a concious decision to convert cells with zeros to NA.
# while zero could be true, it's could be that there are a small number of hotels 
# and that the data was suppressed for confidentiality reasons
data_1 <- read.csv(fname, header = FALSE, sep = ",", skip = 8,
                    na.strings = c("", "NA", "0", "/0"), stringsAsFactors=FALSE)
data_2 <- data_1 %>%
    select(V1,V2, num_range("V",5:ncol(.)))
# applies the row1 column names prepared above
colnames(data_2) <- row1

# uses apply to remove columns that are NA
data_3 <- data_2[, !apply(is.na(data_2), 2, all)] 

# gets to a tidy format
data_4 <- data_3 %>%
  mutate(var = ifelse(var == "Available Rooms", "supt", var)) %>%
  mutate(var = ifelse(var == "Rooms Sold", "demt", var)) %>%
  mutate(var = ifelse(var == "Rooms Rev", "rmrevt", var)) %>%
  filter(var == "supt" | var == "demt" | var == "rmrevt") %>%
  gather(date, value, 4:ncol(.)) %>%
  left_join(., host_str_simp, by=c("geo_text" = "hoststr_text")) %>%
  mutate(seg_abrev = ifelse(seg_text == "All Chain Scales","tot", 
               ifelse(seg_text == "Upscale & Above","upa", 
               ifelse(seg_text == "Luxury","lux", 
               ifelse(seg_text == "Upper Upscale", "upu", 
               ifelse(seg_text == "Upscale","ups", 
                      NA)))))) %>%
  mutate(seg = paste(seg_abrev, hoststr_sh, sep="")) %>%
  select(date, seg, var, value)

# spreads into series in columns
data_5 <- data_4 %>%
  mutate(segvar = paste(seg,var,sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)

# drops columns that are all NA
# haven't figured out a less complex way to write this, but there must be
data_5 <- data_5[, !apply(is.na(data_5), 2, all)]

# extracts the longest contigous portions of each series
# works as follows:
# starts with dataframe with series in columns
# reads to zoo, and then applies the zoo function na.contiguous to each 
# column, returning a list in which each object of the list is a series
# then does do.call merge which zoo recognizes and uses to merge together
# the series as a single zoo object respecting dates, and then convert that
# to a dataframe with a date column
# another consideration would be to run na.spline or na.approx first which
# has an argument to set the max number of NAs to fill, so that might 
# be a good way to fill small holes
raw_str_us_host <- data_5%>%
  read.zoo() %>%
  lapply(., FUN=na.contiguous) %>%
  do.call("merge", .) %>%
  data.frame(date=time(.), .)

c <- colnames(raw_str_us_host)
c
# saves Rdata version of the data
save(raw_str_us_host, file="output_data/raw_str_us_host.Rdata")
