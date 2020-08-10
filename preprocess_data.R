# library(shiny)
# library(tidyverse)
# library(tibbletime)
# library(lubridate)
# library(zoo)
# library(sf)
# library(tmap)
# 
# pollution <- read_csv('~/R_projects/BIOF439/final_project_extra/pollution_us_2000_2016.csv',
#          col_types = cols_only('State' = col_guess(), #guess type
#                                'Date Local' = col_guess(), #guess type
#                                'NO2 AQI' = col_guess(),    #guess type
#                                'O3 AQI' = col_guess(),   #guess type
#                                'SO2 AQI'=col_guess(),
#                                'CO AQI'=col_guess()
#          )
# )
# names(pollution)<-str_replace_all(names(pollution), c(" " = "." , "," = "" ))
# aqi <- pollution %>%
#   filter(State!='Country Of Mexico') %>% # get rid of Mexico
#   drop_na() %>% # drop all rows with na
#   group_by(State, Date.Local) %>% # group by state, date and summarize mean for all 4 AQI types
#   summarize(NO2.AQI = mean(NO2.AQI), O3.AQI = mean(O3.AQI),
#             SO2.AQI = mean(SO2.AQI), CO.AQI = mean(CO.AQI),
#             .groups='keep') %>%
#   ungroup()
# 
# # get mean NO2, O3, SO2, and CO AQI per month for each state
# aqi_monthly <- aqi %>%
#   mutate(year = year(Date.Local), month = month(Date.Local)) %>%
#   group_by(State, year, month) %>%
#   summarize(NO2.AQI = mean(NO2.AQI), O3.AQI = mean(O3.AQI),
#             SO2.AQI = mean(SO2.AQI), CO.AQI = mean(CO.AQI),
#             .groups='keep')
# 
# # get states which we have full data for
# full_states <- aqi_monthly %>% 
#   group_by(State) %>%
#   summarize(no_rows = length(State)) %>% 
#   filter(no_rows>190)
# 
# # filter aqi_monthly to only show states we have full data for
# aqi_monthly <- aqi_monthly %>% 
#   filter(State %in% full_states$State)
# 
# # save csv
# write.csv(aqi_monthly,"~/R_projects/flex_dashboard/pollution.csv", row.names = FALSE)