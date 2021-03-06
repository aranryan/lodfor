
library(directlabels)
library(grid)
library(gridExtra)
library(gtable)
library(Cairo)
library(RColorBrewer)
library(rmarkdown)
library(knitr)

# install.packages("extrafont")
# library(extrafont)
# font_import() # this gets fonts installed anywhere on your computer, 
# most commonly from MS Office install fonts. 
# It takes a long while.
# loadfonts()

#read_chunk('~/Project/R projects/lodfor/scripts/functions.R')
#source('~/Project/R projects/lodfor/scripts/functions.R')
library(arlodr, warn.conflicts=FALSE)
library(xts, warn.conflicts=FALSE)
library(dplyr, warn.conflicts=FALSE)
library(ggplot2, warn.conflicts=FALSE)
library(scales, warn.conflicts=FALSE)
library(lubridate, warn.conflicts=FALSE)
library(tidyr)

fpath <- c("~/Project/R projects/lodfor/")
load(paste(fpath, "output_data/ushist_q.Rdata", sep=""))

# puts the quarterly ushist into a melted data frame
ushist_q_m <- ushist_q %>%
  window(end = as.Date("2017-10-01")) %>%
  data.frame(date=index(.), .) %>%
  gather(variable, value, -date)

#Displays palette and sets the ts1 theme

#display.brewer.pal(10, "RdBu")
mypallete <- brewer.pal( 10 , "RdBu" )
colors_ts1 <- scale_colour_manual(values = mypallete[c(10, 1, 5, 4)])
# I don't use the following, was an example I saw somewhere maybe as a way to 
# interpolate additional palette colors
#mypal <- colorRampPalette( brewer.pal( 10 , "RdBu" ) )
theme_ts1 <- function (base_size = 12, base_family = "Arial") {
  theme_classic(base_size = base_size) %+replace%
    theme(                                 
      panel.grid.major.x=element_blank(),
      panel.grid.minor.x=element_blank(),
      panel.grid.minor.y=element_blank(),
      axis.ticks.y=element_line(size=.2),
      axis.ticks.x=element_line(size=.2),
      panel.background=element_blank(),
      legend.title=element_blank(),
      legend.key=element_rect(fill="white", colour = "white"),
      legend.key.size=unit(1, "cm"),
      legend.text=element_text(size=rel(1)),
      legend.position = c(1, .1),
      legend.position = "none",
      legend.justification = "right",
      axis.line=element_line(size=.2),
      axis.title.y=element_blank(),
      axis.title.x=element_blank(),
      axis.text=element_text(color="black",size=rel(.7)),
      # following seems to adjust y-axis title
      plot.title=element_text(size=base_size * .8, face="plain",hjust=0,vjust=1)
      #theme(plot.title = element_text(lineheight=.8, face="bold"))
    )
}


theme_set(theme_ts1())
#this is also a useful theme to keep in mind
#theme_classic()
# this function gets the settings used by the current theme
#theme_get()


## Occupancy with forecast
#sets variable and text items
todo <- c("totus_occ_sa")
grtitle <- c("Occupancy")

footnote <- c("Note: Seasonally adjusted. History through fourth quarter 2014, forecast through fourth quarter 2017.\nSource: STR; Tourism Economics")
start_mean <- as.Date("2000-01-01") # for mean
end_mean <- as.Date("2014-10-01")

variable_text <- c("")


temp <- ushist_q_m %>% 
  filter(variable == todo, !is.na(value)) 

p1 <- ggplot(temp, aes(x = date, y=value)) +
  ggtitle(variable_text) +
  scale_y_continuous(labels=percent) +
  geom_line(data = temp[temp$date<=as.Date("2014-10-01"),], color=mypallete[10:10], size=.6, linetype = 1)
CairoPNG("output_data/figure_us_overview_graphs/fig-testR400dpi-occupancy_forecast.png", units="in", width=9, height=5.7, dpi=400)
#CairoPDF("output_data/figure_us_overview_graphs/fig-testR400dpi-occupancy_forecast.pdf", width=9, height=5.7)
plot_title_3(plot=p1, grtitle=grtitle, footnote=footnote, filename = c("temp.png"))
dev.off()

plot_title_3(plot=p1, grtitle=grtitle, footnote=footnote, filename = c("temp.png"))
p1 <- ggplot(temp, aes(x = date, y=value)) +
  geom_line(data = temp[temp$date<=as.Date("2014-10-01"),], size=.6, linetype = 1)
p1
ggsave("output_data/figure_us_overview_graphs/fig-test_ggsave_1_R600dpi-occupancy_forecast.png", dpi=600)
ggsave("output_data/figure_us_overview_graphs/fig-test_ggsave_2_R400dpi-occupancy_forecast.pdf")
ggsave("output_data/figure_us_overview_graphs/fig-test_ggsave_3_R600dpi-occupancy_forecast2.png", height=5.5, width=9, dpi=600)


