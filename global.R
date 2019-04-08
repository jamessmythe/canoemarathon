## canoe marathon results app

#-----------LIBRARY LOADING---------------

library(shiny)
library(shinythemes)
library(tidyverse) # group of packages for data wrangling and visualisation (ggplot2)
library(lubridate) # convert date to R date format
library(DT) # Data Tables package for interactive html tables
library(googledrive)
library(openxlsx)

#-------------DATASET LOADING--------------------

drive_download(as_dribble("canoeingresultsDBase.RDS"), overwrite = T)
drive_download(as_dribble("canoeingClubPts.RDS"), overwrite = T)

data <- read_rds("canoeingresultsDBase.RDS") %>% 
  filter(Outcome != "DNS")

clubdata <- read_rds("canoeingClubPts.RDS")

main_data <- data %>% 
  rename(`P/D` = P.D) %>% 
  mutate(Outcome = case_when(is.na(Outcome) ~ "Finish", TRUE ~ Outcome)) %>% 
  #mutate(Date = dmy(Date)) %>%
  mutate(Time = ymd_hms(Time)) %>% 
  mutate(Time = format(Time, format = "%H:%M:%S")) %>%
  select(RaceRegion, Event, Date, Season, Race, Position, Name, Club, Class, Time, Points, Outcome, `P/D`) %>% 
  arrange(desc(Season), Event, Date, Race, Position) %>% 
  mutate(Name2 = paste(Name, "(", Club, ")"))

table_data <- main_data %>% 
  select(-Name2, -RaceRegion)

menus <- main_data %>% 
  select(Season, Event, Race) %>% 
  arrange(desc(Season), Event, Race) %>% 
  unique()

paddlers <- main_data %>% 
  select(Name2) %>% 
  arrange(Name2) %>% 
  unique()

regions <- main_data %>% 
  select(RaceRegion) %>% 
  arrange(RaceRegion) %>% 
  unique()

divs <- main_data %>% 
  select(Race) %>% 
  arrange(Race) %>% 
  unique()

top3s <- main_data %>% 
  select(Name2, Position) %>% 
  filter(Position %in%(c(1,2,3))) %>% 
  group_by(Name2) %>% 
  add_tally() %>% 
  select(-Position) %>% 
  unique()

medals <- main_data %>% 
  select(Name2, Position, Event) %>% 
  filter(Position %in%(c(1,2,3)), Event == "National Championships") %>% 
  group_by(Name2) %>% 
  add_tally() %>% 
  select(-Position) %>% 
  unique()

completeCount <- main_data %>% 
  select(Name2, Position) %>% 
  filter(!is.na(Position)) %>% 
  select(-Position) %>% 
  group_by(Name2) %>% 
  add_tally() %>% 
  unique()

faveEvents <- main_data %>%
  select(Name2, Event) %>% 
  group_by(Name2, Event) %>% 
  add_tally() %>% 
  filter(n>1) %>% 
  arrange(Name2, -n) %>% 
  unique()

rankings <- main_data %>%
  select(Season, Name2, Position) %>% 
  group_by(Season, Name2) %>% 
  add_tally() %>% 
  unique() %>% 
  filter(n>2) %>% 
  summarise(aveFinish = mean(Position, na.rm = TRUE))

qualstatus <- main_data %>% 
  filter(Season == "2018/19", str_detect(Race, "Div") == TRUE, !Outcome %in% c("DNS", "RTD", "DSQ", "rtd", "dsq", "dns")) %>% 
  mutate(Qualname = paste(Name, "-", Club, "-", Class)) %>% 
  select(RaceRegion, Event, Season, Race, Qualname, Club) %>% 
  group_by(Qualname) %>% 
  mutate(RaceCt = n()) %>% 
  ungroup() %>% 
  arrange(Club, desc(RaceCt), Qualname)

clubdata <- clubdata %>% 
  rename(`Race Name` = Race.Name, `Hasler points` = Points) %>% 
  select(`Race Name`, Club, `Hasler points`, Region, Date) %>% 
  group_by(Club) %>% 
  mutate(Total = sum(`Hasler points`)) %>% 
  ungroup() %>% 
  arrange(Region, Date)

promos <- main_data %>% 
  select(Season, Event, Name, Club, `P/D`, Date) %>% 
  filter(str_detect(`P/D`,"P")) %>% 
  filter(Date > today()-months(1)) %>% #change to 1 month from start of season
  arrange(`P/D`, Date)