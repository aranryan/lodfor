library(arlodr)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(tidyr, warn.conflicts=FALSE)
library(readxl)
library(stringr)

########
#
# name of file to read

fname <- c("input_data/TourismEconomicsUS_201603.xls")

# reference file to use in converting market names to shorter abbreviations
str_geoseg <- read.csv("reference/str_geoseg.csv", header = TRUE, sep = ",")

########
#
# load STR data
#

# first read in the first two rows, and grab the names of the markets and 
# segments from the first row
# first2 <- read.csv(fname, header = FALSE, sep = ",", 
#                    nrows=2, stringsAsFactors=FALSE, na.strings=c("", "NA"))
first2 <- read_excel(fname, sheet = 2, col_names = FALSE)

#########
#
# handles first row
#

row1 <- first2[1,2:ncol(first2)]

# uses apply to remove columns that are NA
row1 <- row1[, !apply(is.na(row1), 2, all)]

row1b <- rep(row1[1,], each=3) %>%
  unlist() 

row1b

letters[seq( from = 1, to = 100 )]

# I ran into an issue when I did the spread where
# x10 was showing up before x2 because it was sorting the column
# names. This put the metros out of order. My solution was to
# create a numeric vector that had leading zeros, that prevented
# the undesired sorting.
hold <- str_pad(1:99, 3, pad = "0")

row1c <- data_frame(row1 = row1b, x=hold) %>%
  mutate(x = paste0("x", x)) %>%
  spread(x, row1)


# this is a function that I defined in functions script
# it takes an input dataset, then vector of old values, then a vector of 
# new values and it replaces the old with the new, converting any factors to 
# text along the way
row1d <- recoder_func(row1c, str_geoseg$str_long, str_geoseg$str_geoseg)

###########
# handles second row
#

row2 <- first2[2,2:ncol(first2)]
# simple recoding
row2 <- car::recode(row2, '"Supply" = "supt"; "Demand" = "demt"; 
                    "Revenue" = "rmrevt"')

# create series names


series_names <- paste(row1d, row2, sep="_")
series_names
series_names <- c("date", series_names)
head(series_names)

########
# now read in the table without headers
#

# in the source file there is a footnote that happens at first and second column,
# row 11,000 or so, so this reads in the whole file and then takes only the first 5000 rows
data_m <- read_excel(fname, sheet = 2, col_names = FALSE)
data_m <- data_m[1:5000,]


# this removes rows that are NA in the first column
# effectively it takes those rows that are not NA and keeps them
# based on 
# https://heuristically.wordpress.com/2009/10/08/delete-rows-from-r-data-frame/
data_m <- data_m[!is.na(data_m[,1]),]

# still have the issue that there are commas in the data, this removes them
#col2cvt <- 2:ncol(data_m) # columns from 2 to the end
# runs a function to remove commas and convert to numeric
#data_m[,col2cvt] <- lapply(data_m[,col2cvt],function(x){as.numeric(gsub(",", "", x))})

# names the columns and formats first column as dates
colnames(data_m) <- series_names

# as.yearmon is a format for monthly dates, then I take as.Date of that
data_m2 <- data_m %>%
  as_data_frame() %>%
  mutate(date = as.Date(as.yearmon(format(date, nsmall =2), "%Y%m"))) %>%
  gather(variable, value, -date) %>%
  mutate(value = as.numeric(value)) %>%
  spread(variable, value)

################
#
# does a quick filter on the data, for example if I just want to keep ustot

# list of segments to keep

to_keep <- c("totus")
 to_keep <- c(to_keep, "luxus", "upuus", "upsus", "upmus", "midus", "ecous", "indus")
# 
 to_keep <- c(to_keep
    ,   "anaheim", "atlanta", "boston", "chicago", "dallas" 
     ,"denver", "detroit", "houston", "lalongbeach", "miami" 
     ,"minneapolis", "nashville", "neworleans", "newyork", "norfolk"
     ,"oahu", "orlando", "philadelphia", "phoenix", "sandiego" 
     ,"sanfrancisco", "seattle", "stlouis", "tampa", "washingtondc"
 )

# puts into tidy format with a seg column that contains the segment code
# then filters to keep the segments
raw_str_us <- data_m2 %>% 
  gather(segvar, value, -date, na.rm = FALSE) %>%
  # separate on anything that is in not in the list of all characters and numbers
  separate(segvar, c("seg", "variable"), sep = "[^[:alnum:]]+") %>%
  # filters to keep segments in the list to_keep
  filter(seg %in% to_keep) %>%
  mutate(variable = paste(seg, "_", variable, sep='')) %>%
  select(-seg) %>%
  spread(variable,value) 

# saves Rdata version of the data
save(raw_str_us, file="output_data/raw_str_us.Rdata")
