

# end of data
end_strdata <- "2015-04-01"
start_strdata <- "1987-01-01"

# load various files
load("output_data/recession_df_m.Rdata")
load("output_data/ushist_host_q.Rdata")
load("output_data/ushist_host_m.Rdata")

# list of geos that we want to be sure to cover, even if with NAs
geo_for_eviews <- read.table("input_data/geo_for_eviews_list.txt", header=FALSE, stringsAsFactors=FALSE)
names(geo_for_eviews) <- c("area_sh")

# this is in an actual tidy format with date and seg columns to describe the
# observations, and then variables in the columns
# ushist_q_td <- data.frame(date=time(ushist_q), ushist_q)%>%
#   melt(id.vars = c("date")) %>%
#   separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
#   spread(var, value) 

# this is in an actual tidy format with date and seg columns to describe the
# observations, and then variables in the columns
# top25compile_td <- top25compile %>%
#   select(-contains("adrrpc"), -contains("pc_index")) %>%
#   melt(id.vars = c("date")) %>%
#   separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
#   spread(var, value) %>%
#   filter(seg != "totus")

a <- colnames(ushist_host_q)
a

# this is in an actual tidy format with date and seg columns to describe the
# observations, and then variables in the columns
ushist_host_q_td <- data.frame(date=time(ushist_host_q), ushist_host_q)%>%
  melt(id.vars = c("date")) %>%
  separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
  spread(var, value) 

# just to look at
# a <- filter(ushist_host_q_td, date == "2001-01-01")
# b <- filter(ushist_host_q_td, seg == "totphlpa")

######################
#
# pulling market data

temp1 <- ushist_host_q_td %>%
  filter(seg != "mex" &
         seg != "can" &
         seg!= "us"
         ) %>%
  separate(seg,c("seg","geo"), sep=3) %>%
  select(date, seg, geo, supd_sa, supd, supt, demd_sa, demd, demt, occ_sa, 
         adr_sa, adr_sar, adr, revpar_sa, revpar_sar, revpar, rmrevt)

temp2 <- temp1 %>%
  arrange(date) %>%
  filter(date >= start_strdata) %>%
  filter(date <= end_strdata)

out_e_hststr <- temp2 %>%
  gather(var, value, supd_sa:rmrevt) %>%
  mutate(var = gsub("_", "", var)) %>%
  # temporary fix to rename certain real series
  mutate(var = ifelse(var == "revparsarpc", "revparsar", var)) %>%
  mutate(var = ifelse(var == "adrsarpc", "adrsar", var)) %>%
  mutate(segvar = tolower(paste(var,seg, sep=""))) %>%
  mutate(segvar = paste(segvar, geo, sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)
  
plot(out_e_hststr$adrsarupa_lsaca, type="l")
plot(out_e_hststr$adrsarupa_vnccn, type="l")

# uses function to update dataframe to include 
# NA series for any combination that is missing, which is helpful for Anthony

# starts with list with all intended geos
check_for <- as.character(geo_for_eviews[,1])
# applies function
hold <- check_vargeo(out_e_hststr, check_for)
print("list of missing series") 
hold[2]
# uses dataframe updated to include any missing series as NA
out_e_hststr <- data.frame(hold[1])

# create a tidy copy
out_t_hststr <- out_e_hststr %>%
  gather(vargeo, value, -date) %>%
  separate(vargeo, c("var", "area_sh"), sep = "_", extra="merge") %>%
  spread(var, value)

# saving outputs
write.csv(out_e_hststr, file="output_data/out_e_hststr.csv", row.names=FALSE)
save(out_t_hststr, file=paste("output_data/out_t_hststr.Rdata", sep=""))
