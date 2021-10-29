# STAT 515 Final Project
# Doug Cady
# Apr 2021

# use Nashville, TN data? -----------------

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(lubridate)
source("windows_gui.R")

# Load rds data file ----------------------------------------------------------
# stops_fn <- "../input/yg821jf8611_ri_statewide_2020_04_01.rds"
stops_fn <- "../input/yg821jf8611_tn_nashville_2020_04_01.rds"

stops <- as_tibble(readRDS(stops_fn))

# stops_fn <- '../input/tn_nashville_2020_04_01.csv'

# stops <- read_csv(stops_fn)

# Summary stats and explore data fields
# nrow(stops)
# str(stops)
summary(stops)
glimpse(stops)


# Cleaning data ---------------------------------------------------------------
## Drop 10 NA rows, add year and month vars, factorize other vars
stops_clean <- drop_na(stops, date) %>%
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
# summary(stops_clean)

## By subject race
stops_clean  %>%
    count(subject_race)

## By subject sex
stops_clean  %>%
    count(subject_sex)

## By zone
stops_clean  %>%
    count(zone)

## By stop type (vehicular, traffic, etc)
stops_clean  %>%
    count(type)

## By year
stops_clean %>%
    count(year)
# 2005 has many fewer stops than the rest of the years.
# I think we should remove it.
stops_06_15 <- filter(stops_clean, year > 2005)

summary(stops_06_15)

## By subject sex and race
stops_clean  %>%
    count(subject_sex, subject_race)
# 29063 where sex and race are NAs
# 24 where sex is NA and race is given

## Stops by year and race
stops_06_15 %>%
    count(year, subject_race) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line()

## Stops by year and race and sex
stops_06_15 %>%
    count(year, subject_race, subject_sex) %>%
    filter(subject_sex %in% c("female", "male")) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line() +
    facet_wrap( ~ subject_sex, nrow = 2)

## Hit rates by race
stops_06_15 %>%
    filter(search_conducted) %>%
    group_by(subject_race) %>%
    summarize(hits = sum(contraband_found, na.rm = T),
              hit_rate = mean(contraband_found, na.rm = T))

## Hit rates by race
stops_06_15 %>%
    filter(search_conducted) %>%
    count(subject_race, contraband_found) %>%
    pivot_wider(names_from = contraband_found, values_from = n) %>%
    rename(No_Contra = "FALSE", Yes_Contra = "TRUE") %>%
    mutate(Hit_Rate = round(Yes_Contra / (No_Contra + Yes_Contra), 3))
