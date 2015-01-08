
#######
#
# name of file to read

fname <- c("input_data/str_us_top25.csv")

########
#
# load STR data
#

# first read in the first two rows, and grab the names of the markets and 
# segments from the first row
first2 <- read.csv(fname, header = FALSE, sep = ",", 
                   nrows=2, stringsAsFactors=FALSE, na.strings=c("", "NA"))
row1 <- first2[1,2:ncol(first2)]
# uses apply to remove columns that are NA
row1 <- row1[, !apply(is.na(row1), 2, all)]

# reference file to use in converting market names to shorter abbreviations
str_geoseg <- read.csv("reference/str_geoseg.csv", header = TRUE, sep = ",")

# this is a function that I defined in functions script
# it takes an input dataset, then vector of old values, then a vector of 
# new values and it replaces the old with the new, converting any factors to 
# text along the way
row1 <- recoder_func(row1, str_geoseg$str_long, str_geoseg$str_geoseg)

# repeats each element 3 times, returning a vector
row1 <- rep(row1,each=3)
row1 <- unlist(row1)

# then create row2
row2 <- first2[2,2:ncol(first2)]

# use car::recode for simple recoding
row2 <- recode(row2, '"Supply" = "supt"; "Demand" = "demt"; 
               "Revenue" = "rmrevt"')
row2 <- unlist(row2)
series_names <- paste(row1, row2, sep="_")
series_names <- c("date", series_names)
head(series_names)

# now read in the table without headers
data_m <- read.csv(fname, header = FALSE, sep = ",", skip = 2,
                    na.strings = c("NA", ""), stringsAsFactors=FALSE)
# in the source file there is a footnote that happens at first and second column,
# row 11,000 or so
# this removes rows that are NA in the third column
# effectively it takes those rows that are not NA and keeps them
# based on 
# https://heuristically.wordpress.com/2009/10/08/delete-rows-from-r-data-frame/
data_m <- data_m[!is.na(data_m[,3]),]

# still have the issue that there are commas in the data, this removes them
col2cvt <- 2:ncol(data_m) # columns from 2 to the end
# runs a function to remove commas and convert to numeric
data_m[,col2cvt] <- lapply(data_m[,col2cvt],function(x){as.numeric(gsub(",", "", x))})

# names the columns and formats first column as dates
colnames(data_m) <- series_names
# as.yearmon is a format for monthly dates, then I take as.Date of that
data_m$date <- as.Date(as.yearmon(format(data_m$date, nsmall =2), "%Y%m"))

################
#
# does a quick filter on the data, for example if I just want to keep ustot

# list of segments to keep
to_keep <- c("totus")
to_keep <- c(to_keep, "luxus", "upuus", "upsus", "upmus", "midus", "ecous", "indus")

# to_keep <- c(to_keep,
#      "anaheim", "atlanta", "boston", "chicago", "dallas" 
#    ,"denver", "detroit", "houston", "lalongbeach", "miami" 
#    ,"minneapolis", "nashville", "neworleans", "newyork", "norfolk"
#    ,"oahu", "orlando", "philadelphia", "phoenix", "sandiego" 
#    ,"sanfrancisco", "seattle", "stlouis", "tampa", "washingtondc"
#)

# puts into tidy format with a seg column that contains the segment code
# then filters to keep the segments
a1 <- data_m %>% 
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

raw_str_us <- a1

# saves Rdata version of the data
save(raw_str_us, file="output_data/raw_str_us.Rdata")