emp <- melt(economics, id = "date", measure = c("unemploy", "uempmed"))
range01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / diff(rng)
}
emp2 <- ddply(emp, .(variable), transform, value = range01(value))
head(emp2)
qplot(date, value, data = emp2, geom = "line",
      colour = variable, linetype = variable)
qplot(date, value, data = emp, geom = "line") +
  facet_grid(variable ~ ., scales = "free_y")

rng <- range(economics$unemploy, na.rm = TRUE)
rng
rng[1]
diff(rng)
# rng returns the min and max
# so diff(rng) is the max minus the min
# so range is taking each value, subracting the min, and then dividing
# by the range.
