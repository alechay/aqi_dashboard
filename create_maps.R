library(shiny)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(tibbletime)
library(lubridate)
library(zoo)
library(usmap)
library(USAboundariesData)
library(sf)
library(tmap)

# LOAD AND PROCESS DATA

# read csv into data frame and remove unecessary columns
pollution <- read_csv('~/R_projects/BIOF439/final_project_extra/pollution_us_2000_2016.csv')
names(pollution)<-str_replace_all(names(pollution), c(" " = "." , "," = "" ))
pollution <- pollution %>%
  select(-1) %>%
  subset(select=-c(State.Code,County.Code,Site.Num,Address,NO2.Units,O3.Units,SO2.Units,CO.Units)) %>%
  filter(State!='Country Of Mexico')

# subset df to only include variables of interest
aqi <- subset(pollution, select=c(State, Date.Local, NO2.AQI, O3.AQI, SO2.AQI, CO.AQI))
# some entries have several values for observation date
# code below manages that by dropping na and averaging across date and state
aqi <- aqi %>%
  drop_na() %>%
  group_by(State, Date.Local) %>%
  summarize(NO2.AQI = mean(NO2.AQI), O3.AQI = mean(O3.AQI),
            SO2.AQI = mean(SO2.AQI), CO.AQI = mean(CO.AQI),
            .groups='keep') %>%
  ungroup()

# get mean NO2, O3, SO2, and CO AQI per month for each state
aqi_monthly <- aqi %>%
  mutate(year = year(Date.Local), month = month(Date.Local)) %>%
  group_by(State, year, month) %>%
  summarize(NO2.AQI = mean(NO2.AQI), O3.AQI = mean(O3.AQI),
            SO2.AQI = mean(SO2.AQI), CO.AQI = mean(CO.AQI),
            .groups='keep') %>%
  select(everything()) %>%
  mutate(Date = as.yearmon(paste(year, month), "%Y %m"))

# get mean NO2, O3, SO2, and CO AQI overtime for each state
aqi_avg <- aqi_monthly %>%
  group_by(State) %>%
  summarize(NO2.AQI = mean(NO2.AQI), O3.AQI = mean(O3.AQI),
            SO2.AQI = mean(SO2.AQI), CO.AQI = mean(CO.AQI),
            .groups='keep') %>%
  gather('NO2.AQI', 'O3.AQI', 'SO2.AQI', 'CO.AQI',
         key='type', value='AQI') %>%
  mutate(type = str_remove(type, '\\.AQI$'))

# get states which we have full data for
full_states <- aqi_monthly %>%
  group_by(State) %>%
  summarize(no_rows = length(State)) %>%
  filter(no_rows>190)

# filter aqi_monthly to only show states we have full data for
aqi_monthly <- aqi_monthly %>%
  filter(State %in% full_states$State)

# use gather to get tidy monthly data for the types of AQI
tidy <- aqi_monthly %>%
  gather('NO2.AQI', 'O3.AQI', 'SO2.AQI', 'CO.AQI',
         key='type', value='AQI') %>%
  mutate(type = str_remove(type, '\\.AQI$'))

# to plot bar graphs of state AQI for each type and each month
plot_data <- tidy %>%
  group_by(State, month, type) %>%
  summarize(AQI = mean(AQI), .groups='keep')

# function monthStart forces the date to the first date of that month and year
monthStart <- function(x) {
  x <- as.POSIXlt(x)
  x$mday <- 1
  as.Date(x)
}

# specify group colors for plot
group.colors <- c(NO2 = "#7CAE00", O3 = "#00BFC4", SO2 ="#C77CFF", CO = "#F8766D")

# months
month.list <- c('January','February','March','April','May','June',
                'July','August','September','October','November','December')
month.number <- c(1:12)
names(month.number) <- month.list

################################################################################

# map visualization: I pre-created the gifs that are rendered in shiny

# load states geographic data
states <- st_as_sf(maps::map(database = "state",plot=F,fill=T))
states <- states %>%
  mutate(ID = stringr::str_to_title(ID))

# for (x in c('NO2', 'O3', 'SO2', 'CO')){
#   # join the AQI data with the state geometry data
#   joined_geom_data <- tidy %>%
#     left_join(states %>% select(ID, geom),
#               by = c('State' = 'ID')) %>%
#     filter(type==x) # filter to just include 'NO2' type
#   # set the geom column as the sf geometry column
#   joined_geom_data <- st_as_sf(joined_geom_data)
# 
# 
#   aqi_anim <- tm_shape(states) + tm_polygons() +
#     tm_shape(joined_geom_data) + tm_polygons(col = "AQI") +
#     tm_facets(along = "Date", free.coords = FALSE) +
#     tm_layout(main.title = paste(sort(unique(joined_geom_data$Date)), x))
# 
#   tmap_animation(aqi_anim, filename = paste(x, ".gif", sep = ''))
# }