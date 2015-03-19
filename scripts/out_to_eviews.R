
# defined list
seg_l <- c("totus", "luxus", "upuus", "upsus", "upmus", "midus", "ecous", "indus")


# load various files
load("output_data/ushist_m.Rdata")
load("output_data/outf_str_us_m.Rdata")
load("output_data/ushist_q.Rdata")
load("output_data/usfor_q.Rdata")
load("output_data/recession_df_m.Rdata")
load("output_data/top25compile.Rdata")

colcl <- c("character", "character")
cw_str_geoseg <- read.csv("input_data/str_geoseg_to_area_name_cen.csv", colClasses=colcl)

# imports list of MSAs based on Census and corresponding BLS codes
colc <- rep("character", 10)
m_cen_blsces <- read.csv("input_data/m_cen_blsces.csv", head=TRUE, colClasses=colc) 
str(m_cen_blsces)

#  a <- colnames(ushist_q) 
#  a

# this is in an actual tidy format with date and seg columns to describe the
# observations, and then variables in the columns
ushist_q_td <- data.frame(date=time(ushist_q), ushist_q)%>%
  melt(id.vars = c("date")) %>%
  separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
  spread(var, value) 

# this is in an actual tidy format with date and seg columns to describe the
# observations, and then variables in the columns
top25compile_td <- top25compile %>%
  select(-contains("adrrpc"), -contains("pc_index")) %>%
  melt(id.vars = c("date")) %>%
  separate(variable, c("seg", "var"), sep = "_", extra="merge") %>%
  spread(var, value) %>%
  filter(seg != "totus")

######################
#
# pulling market data


temp1 <- ushist_q_td %>%
  filter(seg != "top25us" &
         seg != "mex" &
         seg != "can" &
         seg!= "us"
         ) %>%
  # filters for seg not in the seg_l list, so just msas
  filter(!(seg %in% seg_l)) %>%
 # converts str_geoseg to msa area names from census
  left_join(., cw_str_geoseg, by=c("seg" = "str_geoseg")) %>%
  filter(! is.na(area_name_cen)) %>%
  select(-seg, -str_long) %>%
  rename(seg = area_name_cen) %>%
  select(date, seg, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc) %>%
  filter(date >= "1987-01-01") %>%
  # merges on msa codes
  left_join(., m_cen_blsces, by=c("seg" = "area_name_cen")) %>%
  mutate(seg = area_sh) %>%
  select(date, seg, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc)

############
#
# pulling top 25 data

temp2 <- top25compile_td %>%
  filter(seg == "top25us") %>%
  select(date, seg, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc) 
# %>%
  # add columns that are set to na but help with the rbind
#   mutate(occ_sa = NA, adr_sa = NA, adr_sarpc = NA, revpar_sa = NA, revpar_sarpc = NA)

###########
#
# pulling chain and totus data

temp3 <- ushist_q_td %>%
  filter(seg %in% seg_l) %>%
  select(date, seg, supd_sa, demd_sa, occ_sa, adr_sa, adr_sarpc, revpar_sa, revpar_sarpc) %>%
  filter(date >= "1987-01-01")

##########
#
# combining all and creating output file

temp4 <- rbind(temp1, temp2, temp3) %>%
  arrange(date) %>%
  filter(date <= "2014-10-01")

out_e_strmk <- temp4 %>%
  gather(var, value, supd_sa:revpar_sarpc) %>%
  mutate(var = gsub("_", "", var)) %>%
  # temporary fix to rename certain real series
  mutate(var = ifelse(var == "revparsarpc", "revparsar", var)) %>%
  mutate(var = ifelse(var == "adrsarpc", "adrsar", var)) %>%
  mutate(segvar = tolower(paste(var,seg, sep="_"))) %>%
  select(date,segvar,value) %>%
  spread(segvar, value)
  
seg_list <- out_e_strmk %>%
  melt(id.vars = c("date")) %>%
  separate(variable, c("var", "seg"), sep = "_", extra="merge") %>%
  select(seg) %>%
  distinct(seg) 
seg_list <- seg_list$seg
str(seg_list)

write.csv(out_e_strmk, file="output_data/out_e_strmk.csv", row.names=FALSE)
write(seg_list, file="output_data/out_seg_list.txt")
