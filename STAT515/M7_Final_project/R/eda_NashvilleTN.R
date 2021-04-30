# STAT 515 Final Project
# Doug Cady
# Apr 2021


library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(ggplot2)
library(lubridate)
source("windows_gui.R")
source("../../R_source_files/hw.R")

# Load rds data file ----------------------------------------------------------
stops_fn <- "../input/yg821jf8611_tn_nashville_2020_04_01.rds"

stops <- as_tibble(readRDS(stops_fn))


# Summary stats and explore data fields
# nrow(stops)
# str(stops)
# names(stops)
# summary(stops)
# glimpse(stops)


# Cleaning data ---------------------------------------------------------------
stops <- stops %>%
    mutate(year = year(date),
           month = month(date))

# EDA -------------------------------------------------------------------------
# summary(stops_clean)

## By subject race
stops  %>%
    count(subject_race)

## By subject sex
stops  %>%
    count(subject_sex)

## By zone
stops  %>%
    count(zone)

## By stop type (vehicular, traffic, etc)
stops  %>%
    count(type)

## By year
stops %>%
    count(year)
# 2005 has many fewer stops than the rest of the years.
# I think we should remove it.
stops_10_18 <- filter(stops, year < 2019)

summary(stops_10_18)

## By subject sex and race
stops  %>%
    count(subject_sex, subject_race)
# 29063 where sex and race are NAs
# 24 where sex is NA and race is given

## Stops by year and race
stops_10_18 %>%
    count(year, subject_race) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line()

## Stops by year and race and sex
stops_10_18 %>%
    count(year, subject_race, subject_sex) %>%
    filter(subject_sex %in% c("female", "male")) %>%
    ggplot(aes(x = year, y = n, color = subject_race)) +
    geom_line() +
    facet_wrap( ~ subject_sex, nrow = 2)

## Hit rates by race
stops_10_18 %>%
    filter(search_conducted) %>%
    group_by(subject_race) %>%
    summarize(hits = sum(contraband_found, na.rm = T),
              hit_rate = mean(contraband_found, na.rm = T))

## Hit rates by race
stops_10_18 %>%
    filter(search_conducted) %>%
    count(subject_race, contraband_found) %>%
    pivot_wider(names_from = contraband_found, values_from = n) %>%
    rename(No_Contra = "FALSE", Yes_Contra = "TRUE") %>%
    mutate(Hit_Rate = round(Yes_Contra / (No_Contra + Yes_Contra), 3))


## Violation types
stops_10_18 %>%
    count(violation) %>%
    filter(!is.na(violation)) %>%
    ggplot(aes(x = reorder(violation, n), y = n)) +
    geom_col(width = 0.8) +
    coord_flip() +
    labs(y = '# of Stops', x = '',
         title = 'EDA - Distribution of Police Stop Violations')


## Violation types by sex
viols_sex <- stops_10_18 %>%
    count(subject_sex, violation) %>%
    filter(!is.na(violation)) %>%
    filter(!is.na(subject_sex)) %>%
    mutate(subject_sex = factor(subject_sex, levels = c("female", "male")))

gg_viols_sex <- viols_sex %>%
    ggplot(aes(x = reorder(violation, n), y = n/1000, fill = subject_sex)) +
    geom_col(width = 0.8, position = "dodge") +
    coord_flip() + hw +
    annotate("text", x = 8.2, y = 825, label = "Male",
             size = 5, color = "black") +
    annotate("text", x = 7.8, y = 525, label = "Female",
             size = 5, color = "black") +
    scale_y_continuous(limits = c(0, 1000)) +
    # guides(fill = guide_legend(reverse = TRUE)) +
    labs(y = '# of Stops (Thousands)', x = '',
         title = "Males get stopped more than females in Nashville, TN",
         subtitle = "Police Stop Violations from 2010-2018",
         caption = "Source: Stanford Open Policing Project") +
    theme(legend.position = "none",
          # legend.position = c(0.8, 0.2),
          # legend.title = element_blank(),
          # legend.text = element_text(size = 11),
          axis.text = element_text(size = 11),
          strip.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

gg_viols_sex

ggsave(filename = "../graphics/eda1_violations_sex.png",
       width = 7, height = 7, units = "in")


## Outcome types by sex
outcome_sex <- stops_10_18 %>%
    count(subject_sex, outcome) %>%
    filter(!is.na(outcome)) %>%
    filter(!is.na(subject_sex)) %>%
    mutate(subject_sex = factor(subject_sex, levels = c("female", "male")))

gg_outcome_sex <- outcome_sex %>%
    ggplot(aes(x = reorder(outcome, n), y = n/1000, fill = subject_sex)) +
    geom_col(width = 0.8, position = "dodge") +
    coord_flip() + hw +
    scale_y_continuous(limits = c(0, 1500)) +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(y = '# of Stops (Thousands)', x = '',
         title = "Males get stopped more than females",
         subtitle = 'Distribution of Police Stop Violations',
         caption = "Source: Stanford Open Policing Project") +
    theme(legend.position = c(0.8, 0.2),
          legend.title = element_blank(),
          legend.text = element_text(size = 11),
          axis.text = element_text(size = 11),
          strip.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

gg_outcome_sex

ggsave(filename = "../graphics/eda2_outcome_sex.png",
       width = 7, height = 7, units = "in")


## Violations by sex and outcome
viols_outcome_sex <- stops_10_18 %>%
    count(subject_sex, outcome, violation) %>%
    filter(!is.na(outcome)) %>%
    filter(!is.na(subject_sex)) %>%
    filter(!is.na(violation)) %>%
    mutate(subject_sex = factor(subject_sex, levels = c("female", "male")))

gg_viols_outcome_sex <- viols_outcome_sex %>%
    ggplot(aes(x = reorder(violation, n), y = n/1000, fill = subject_sex)) +
    geom_col(width = 0.8, position = "dodge") +
    coord_flip() + hw +
    # scale_y_continuous(limits = c(0, 1500)) +
    facet_grid( ~ outcome) +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(y = '# of Stops (Thousands)', x = '',
         title = "Males get stopped more than females",
         subtitle = 'Distribution of Police Stop Violations by Outcome') +
    theme(legend.position = c(0.5, 0.2),
          legend.title = element_blank(),
          legend.text = element_text(size = 10.5),
          axis.text = element_text(size = 11),
          strip.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

gg_viols_outcome_sex

ggsave(filename = "../graphics/eda3_viols_outcome_sex.png",
       width = 7, height = 7, units = "in")


## Violation types by race
# viols_race <- stops_10_18 %>%
#     count(subject_race, outcome) %>%
#     filter(!is.na(outcome)) %>%
#     filter(!is.na(subject_race))
#     # mutate(subject_race = factor(subject_race, levels = c("female", "male")))

# gg_viols_race <- viols_race %>%
#     ggplot(aes(x = reorder(outcome, n), y = n/1000, fill = subject_race)) +
#     geom_col(width = 0.8, position = "dodge") +
#     coord_flip() + hw +
#     # scale_y_continuous(limits = c(0, 1000)) +
#     # guides(fill = guide_legend(reverse = TRUE)) +
#     labs(y = '# of Stops (Thousands)', x = '',
#          title = "Males get stopped more than females",
#          subtitle = 'Distribution of Police Stop Violations') +
#     theme(legend.position = "none",
#           # legend.position = c(0.8, 0.2),
#           # legend.title = element_blank(),
#           # legend.text = element_text(size = 11),
#           axis.text = element_text(size = 11),
#           strip.text = element_text(size = 11),
#           plot.title = element_text(size = 14),
#           plot.subtitle = element_text(face = 'italic'))

# gg_viols_race

# ggsave(filename = "../graphics/eda1_violations_sex.png",
#        width = 7, height = 7, units = "in")


## 2018 stops by race and time of day
pop_2018_fn  <- '../input/tn_nashville_2018_censusPop.xlsx'
pop_2018 <- read_excel(pop_2018_fn)

stops_2018 <- stops_10_18 %>%
    filter(year == 2018,
           !subject_race %in% c('unknown', 'other')) %>%
    filter(!is.na(subject_race)) %>%
    filter(!is.na(subject_sex)) %>%
    filter(!is.na(violation)) %>%
    filter(!is.na(outcome)) %>%
    filter(!is.na(time)) %>%
    mutate(hour = hour(time),
           stop_night = (hour < 7) | (hour >= 20)) %>%
    left_join(pop_2018, by = "subject_race") %>%
    select(subject_sex, subject_race, hour,
           stop_night, violation, outcome, race_pop) %>%
    count(subject_sex, subject_race, hour,
          stop_night, violation, outcome, race_pop)

stops_2018_race_night <- stops_2018 %>%
    group_by(subject_race, race_pop, stop_night) %>%
    summarize(ct = sum(n)) %>%
    mutate(stops_per_1k = ct / race_pop * 1000,
           stopped_daynight = if_else(stop_night, "Night", "Day*"),
           night_pchg = if_else(stop_night,
               paste0(round((stops_per_1k / lag(stops_per_1k) - 1) * 100, 0), "%"),
               ""))

day_night_colors = c("Night" = "#001A26", "Day*" = "#EF810E")

gg_race_time <- stops_2018_race_night %>%
    ggplot(aes(x = reorder(subject_race, stops_per_1k), y = stops_per_1k,
               fill = stopped_daynight)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = night_pchg), hjust = -0.4) +
    coord_flip() + hw +
    scale_fill_manual(values = day_night_colors) +
    facet_grid( ~ stopped_daynight) +
    guides(fill = "none") +
    labs(x = "", y = "Stops Per 1,000 Persons",
         title = "Black people are stopped the most at day and night",
         subtitle = "Nashville, TN Police Stops from 2010-2018",
         caption = paste0("Source: Stanford Open Policing Project",
                          "\nUS Census Bureau 2019 Population Estimates",
                          "\n\n*Day defined as 7AM - 7:59PM. All group raw stop counts > 1000")) +
    theme(axis.text = element_text(size = 11),
          strip.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

gg_race_time


ggsave(filename = "../graphics/eda4_race_daynight.png",
       width = 7, height = 7, units = "in")

# table(stops_2018$subject_race)
# tail(stops_2018[, c("time", "hour", "stop_night")], 25)

