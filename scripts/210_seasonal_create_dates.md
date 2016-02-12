# Create seasonal dummy and dates
Tourism Economics  
January 9, 2016  




The goal of this script is to create a dataframe with a useful set of holiday regressors. 

I originally approached it by creating a date vector for each holiday. But moving those around in lists got difficult. And I switched to creating a single daily data frame as the export

As a first step, I'll handle some easy holidays that are on the same date each year.




Import some csv files that I manually created based on the timeanddate website. Pretty easy.







## What to save
Set up to save a daily data frame with the holidays as dummy variables. Also save the date vectors.


