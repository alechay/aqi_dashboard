# AQI Dashboard
Made an R Shiny dashboard to visualize trends in air quality index (AQI) from 2000-2016

https://alec-hay.shinyapps.io/flex_dashboard/

## Data Source
- https://www.kaggle.com/sogun3/uspollution
- Data was originally scraped from the database of U.S. EPA : https://aqsdr1.epa.gov/aqsweb/aqstmp/airdata/download_files.html
- The Kaggle user gathered four major pollutants (Nitrogen Dioxide, Sulphur Dioxide, Carbon Monoxide and Ozone) for every day from 2000 - 2016 and placed them neatly in a CSV file.

## Data
- In the original CSV file, there were a total of 28 fields. 
- The first 7 fields contained information about the location.
- The 8th field contained the date of the observation.
- The next 20 fields contained information about the pollutants (NO2, O3, SO2 and CO), which each has 5 specific columns. 
- Observations totaled to over 1.4 million.
- Each observation consisted of a location, a date, and information about the four major pollutants for that date.

## What is AQI? How is it calculated?
- AQI stands for air quality index. Low AQI is good, high AQI is bad.
- You can calculate an AQI value for each pollutant, as was done in this data set.
- The formula is 
<br>
<img src="https://github.com/alechay/aqi_dashboard/blob/master/readme_images/Calculate_AQI.png" width=50% height=50% />
- To calculate:
<br>
<img src="https://github.com/alechay/aqi_dashboard/blob/master/readme_images/AQI_Table.png" width=50% height=50% />
- If you wanted to determine the overall AQI, you would look at the pollutant with the highest index.  For example, if NO2 is 125, O3 is 50, SO2 is 30, and CO is 50, and all other pollutants are less than 125, then the AQI is 125–determined ONLY by the concentration of NO2.

## Preprocessing
1. I was only interested in information about the air quality index (AQI) for each pollutant, so I selected 6 columns: State, Date, NO2 AQI, O3 AQI, SO2 AQI, and CO AQI
2. I grouped the data by state then date and found the average AQI (for each of the 4 pollutants) in each state for each day.
3. I grouped the data by state then month and found the average AQI (for each of the 4 pollutants) in each state for each month from 2000-2016. This is the .csv that is included in the repository, as the much smaller file size was more compatible with the R shiny dashboard

## Visualizations
1. Line plot showing AQI over time. Each point is the average AQI in a particular month. You can select the state, type of AQI, and date range for which you want to see the data. You can also facet the plot to show all 4 AQI measures.
2. Bar plot comparing state AQI's against each other. This was a bit more complicated so I'll give an example of how it works. When January is selected, I take the January AQI in each year from 2000-2016 and average that together. I did this for each state. This gives you the average AQI in January from 2000-2016 in each state. You can choose which month, and which type of AQI you want to compare. Also, if you click "all months" it takes the average AQI of all months between 2000-2016. This way you can compare all time state AQI averages against each other.
3. Animated maps showing state AQI over time. You can easily compare state AQI's against each other, and watch how the state AQI's changed over the course of months and years. You can select which AQI type to visualize.
