
# defined list
seg_l <- c("totus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous", "indus")


# load various files
#load("output_data/outf_str_us_m.Rdata")
#load("output_data/ushist_q.Rdata")
#load("output_data/usfor_q.Rdata")
load("output_data/recession_df_m.Rdata")
load("output_data/ushist_host_q.Rdata")
load("output_data/ushist_m.Rdata")


colcl <- c(rep("character", 4))
host_str_simp <- read.csv("input_data/host_str_simp.csv", colClasses=colcl)

# imports list of MSAs based on Census and corresponding BLS codes
colc <- rep("character", 10)
m_cen_blsces <- read.csv("input_data/m_cen_blsces.csv", head=TRUE, colClasses=colc) 
str(m_cen_blsces)

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

a <- filter(ushist_host_q_td, date == "2001-01-01")

a <- filter(ushist_host_q_td, seg == "upana")
#b <- filter(ushist_host_q_td, seg == "totslm")
######################
#
# pulling market data


temp1 <- ushist_host_q_td %>%
  filter(seg != "top25us" &
         seg != "mex" &
         seg != "can" #&
         #seg!= "us"
         ) %>%
  # filters for seg not in the seg_l list, so just msas
  #filter(!(seg %in% seg_l)) %>%
  separate(seg,c("seg","geo"), sep=3) %>%
 # converts str_geoseg to msa area names from census
  left_join(., host_str_simp, by=c("geo" = "hoststr_sh")) %>%
  # manually names Orange County, otherwise Los Angeles shows up twice
  mutate(area_name_simp = ifelse(geo == "org", "Orange County, CA", area_name_simp)) %>%  
  filter(! is.na(area_name_simp)) %>%
  select(date, seg, area_name_simp, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc) %>%
  filter(date >= "1987-01-01") %>%
  # merges on msa codes
  left_join(., m_cen_blsces, by=c("area_name_simp" = "area_name_simp")) %>%
  # manually applies an area_sh code for Orange County Host STR data
  mutate(area_sh = ifelse(area_name_simp == "San Francisco and San Jose, CA", "sfjca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Orange County, CA", "orgca", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui, HI", "mauhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Oahu, HI", "oahhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "Maui and Oahu, HI", "mouhi", area_sh)) %>%
  mutate(area_sh = ifelse(area_name_simp == "United States", "usxxx", area_sh)) 
  #mutate(area_sh = ifelse(area_name_simp == "Selected markets", "slmxx", area_sh))
  
# pause to create a list of area_sh codes and the corresponding market names
  mkt_list <- temp1 %>%  
   select(area_sh, area_name_simp, area_name_cen) %>%
   distinct(., area_sh)
  
temp2 <- temp1 %>%
  select(date, seg, area_sh, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc) 

#%>%
#  mutate(seg = paste(seg, area_sh, sep="")) %>%
#  select(-area_sh)

temp3 <- rbind(temp2) %>%
  arrange(date) %>%
  filter(date <= "2014-10-01")

out_e_hststr <- temp3 %>%
  gather(var, value, supd_sa:revpar_sarpc) %>%
  mutate(var = gsub("_", "", var)) %>%
  # temporary fix to rename certain real series
  mutate(var = ifelse(var == "revparsarpc", "revparsar", var)) %>%
  mutate(var = ifelse(var == "adrsarpc", "adrsar", var)) %>%
  mutate(segvar = tolower(paste(var,seg, sep=""))) %>%
  mutate(segvar = paste(segvar, area_sh, sep="_")) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)
  
plot(out_e_hststr$adrsartot_lsaca, type="l")

# seg_list <- out_e_hststr %>%
#   melt(id.vars = c("date")) %>%
#   separate(variable, c("var", "seg"), sep = "_", extra="merge") %>%
#   select(seg) %>%
#   distinct(seg) 
# seg_list <- seg_list$seg
# str(seg_list)

write.csv(out_e_hststr, file="output_data/out_e_hststr.csv", row.names=FALSE)
# write(seg_list, file="output_data/out_seg_list.txt")
write.csv(mkt_list, file="output_data/mkt_list.csv")
