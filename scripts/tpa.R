
require(readr)

fname1 <- c("input_data/property_data.txt")
fname2 <- c("input_data/reviewdata.txt")
fname3 <- c("input_data/property_pageview_data.txt")


# property data

# readr approach didn't work well, as at some point it didn't split well, maybe when property type is missing
#pdat_dat <- read_table(fname1, n_max = 50000)
#pdat_dat <- read_table(fname1)

pdat_dat <- readLines(fname1)
#pdat_dat <- readLines(fname1, n = 50000)
pdat_dat <- data_frame(pdat_dat)
colnames(pdat_dat) <- c("temp")



pdat_simp <- pdat_dat %>%
  separate(temp, c("property_id", "primary_name", "size_name", "property_type"), sep = "\\|", extra="merge") 
pdat_simp

b <- pdat_simp[19150:20000,]
b

b <- unique(pdat_simp$property_type)
b

save(pdat_simp, file="output_data/pdat_simp.Rdata")

# review data

rdat_simp <- read_delim(fname2, n_max = 500, delim="\\|")
colnames(rdat_simp) <- c("temp")
rdat_simp <- rdat_simp %>%
  separate(temp, c("property_id", "year", "total_rating", "mgmt_responses", "total_reviews"), sep = "\\|", extra="merge") 
rdat_simp

# page views

vdat_simp <- read_delim(fname3, n_max = 500, delim="\\|")
vdat_simp
colnames(vdat_simp) <- c("temp")
vdat_simp <- vdat_simp %>%
  separate(temp, c("year", "location_id", "pageviews"), sep = "\\|", extra="merge") 
vdat_simp
