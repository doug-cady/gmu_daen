# STAT 515 Final Project
# Doug Cady
# Apr 2021

library(dplyr)
library(ggplot2)
library(lubridate)
source("windows_gui.R")

# Load rds data file ----------------------------------------------------------
ri_stops_fn <- "../input/yg821jf8611_ri_statewide_2020_04_01.rds"

ri_stops <- as_tibble(readRDS(ri_stops_fn))

# Summary stats and explore data fields
# str(ri_stops)
# summary(ri_stops)
# glimpse(ri_stops)


# Cleaning data ---------------------------------------------------------------
## Drop 10 NA rows, add year and month vars, factorize other vars
ri_stops_clean <- drop_na(ri_stops, date) %>%
    rename(dept_id = department_id,
           veh_make = vehicle_make,
           veh_model = vehicle_model) %>%
    mutate(year = year(date),
           month = month(date),
           zone = factor(zone),
           dept_id = factor(dept_id),
           veh_make = factor(veh_make),
           veh_model = factor(veh_model))


# EDA -------------------------------------------------------------------------
# summary(ri_stops_clean)

## By subject race
ri_stops_clean  %>%
    count(subject_race)

## By subject sex
ri_stops_clean  %>%
    count(subject_sex)

## By zone
ri_stops_clean  %>%
    count(zone)

## By stop type (vehicular, traffic, etc)
ri_stops_clean  %>%
    count(type)

## By year
ri_stops_clean %>%
    count(year)
# 2005 has many fewer stops than the rest of the years.
# I think we should remove it.
ri_stops_06_15 <- filter(ri_stops_clean, year > 2005)

## By sbuject sex and race
ri_stops_clean  %>%
    count(subject_sex, subject_race)
# 29063 where sex and race are NAs
# 24 where sex is NA and race is given


## Stops by year and race
ri_stops_06_15 %>%
    count(year, subject_race) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line()

## Stops by year and race and sex
ri_stops_06_15 %>%
    count(year, subject_race, subject_sex) %>%
    filter(subject_sex %in% c("female", "male")) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line() +
    facet_wrap( ~ subject_sex, nrow = 2)
