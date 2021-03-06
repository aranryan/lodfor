
library(quantmod)
# sets up recession dates based on 
# http://stackoverflow.com/questions/21739012/r-recession-dates-conversion
getSymbols("USREC",src="FRED")
start_rec <- index(USREC[which(diff(USREC$USREC)==1)])
end_rec   <- index(USREC[which(diff(USREC$USREC)==-1)-1])
recession_df_m <- data.frame(start_rec=start_rec, end_rec=end_rec[-1])

# this series has a lag to it. For example, in 2016 it only went through 2014. 
# It's that way on the Fred website. Presumably because there is a lag in dating
# recessions.

# saves Rdata version
save(recession_df_m, file="output_data/recession_df_m.Rdata")
