


# wrties out various files
write.zoo(out_m_xts, file="~/Project/R projects/lodging graphs/output_data/out_m.csv", sep=",")
write.zoo(out_q_xts, file="~/Project/R projects/lodging graphs/output_data/out_q.csv", sep=",")

write.zoo(out_m_xts_us, file="~/Project/R projects/lodging graphs/output_data/out_m_us.csv", sep=",")
write.zoo(out_q_xts_us, file="~/Project/R projects/lodging graphs/output_data/out_q_us.csv", sep=",")

save(out_m_xts, file="~/Project/R projects/lodging graphs/output_data/outmxts.Rdata")
save(out_q_xts, file="~/Project/R projects/lodging graphs/output_data/outqxts.Rdata")

