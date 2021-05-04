# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219

# Part 1: Exploratory data analysis
# -----------------------------------------------------------------------------


library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(ggplot2)
library(gridExtra)
library(RColorBrewer)
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


# Data Preparation ------------------------------------------------------------
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

## By outcome
stops %>%
    count(outcome)

levels(stops$outcome)

filter(stops, year == 2019) %>%
    count(month)

table(stops$year, stops$month)

# table(stops$subject_race, stops$subject_sex)

# 2005 has many fewer stops than the rest of the years.
# I think we should remove it.
stops_10_18_init <- filter(stops, year < 2019) %>%
    select(date, year, month, time, lat, lng, subject_age, subject_race,
           subject_sex, violation, outcome, frisk_performed, search_conducted,
           contraband_found, contraband_drugs, contraband_weapons)

summary(stops_10_18_init)
glimpse(mutate(stops_10_18_init, violation = factor(violation)))
unique(stops_10_18$violation)
head(stops_10_18$time, 20)


stops_10_18 <- stops_10_18_init %>%
    mutate(violation = if_else(violation == "moving traffic violation",
                               "moving traffic\nviolation",
                       if_else(violation == "vehicle equipment violation",
                               "vehicle equipment\nviolation",
                                violation)))


## By subject sex and race
stops_10_18_init  %>%
    count(subject_sex, subject_race) %>%
    pivot_wider(names_from = "subject_sex", values_from = "n")


## Stops by year and race
stops_10_18_init %>%
    count(year, subject_race) %>%
    # filter(!is.na(subject_race),
    #        subject_race != "unknown") %>%
    ggplot(aes(x = year, y = n)) +
    geom_line(color = "blue4") +
    facet_wrap( ~ subject_race) +
    scale_x_continuous(breaks = c(2010, 2012, 2014, 2016, 2018)) +
    labs(x = '', y = '',
         title = "Stops by Year and Subject Race")

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


## Violation types  (*in pres*)
gg_viols_init <- stops_10_18 %>%
    count(violation) %>%
    filter(!is.na(violation)) %>%
    ggplot(aes(x = n, reorder(violation, n))) +
    geom_col(width = 0.8, fill = "blue4") + hw +
    scale_x_continuous(labels = function(x) {x / 1000000}) +
    labs(x = '# of Stops (Millions)', y = '',
         title = 'EDA - Distribution of Police Stop Violations',
         caption = "Source: Stanford Open Policing Project") +
    theme(axis.text = element_text(size = 14),
          plot.title = element_text(size = 16, face = "italic"),
          axis.title = element_text(size = 14))

ggsave(filename = "../graphics/eda0_violations_init.png",
       width = 7, height = 7, units = "in")


## Violation types by sex -----------------------------------------------------
viols_sex <- stops_10_18 %>%
    count(subject_sex, violation) %>%
    filter(!is.na(violation)) %>%
    filter(!is.na(subject_sex)) %>%
    mutate(subject_sex = factor(subject_sex, levels = c("female", "male"))) %>%
    arrange(desc(n), violation)

grps <- paste0("G", 1:2)
viols_sex$Grp <- factor(rep(grps, each = 8), levels=grps)

viols_sex$violation <- reorder(viols_sex$violation, viols_sex$n)

sex_labels <- data.frame(
    n = c(630000, 455000),
    violation = c(3.2, 2.8),
    lab = c("Male", "Female"),
    subject_sex = c("Male", "Female"),
    Grp = factor(c("G1", "G1"), levels = c("G1", "G2")))

ct_labels <- data.frame(
    n = c(30000, 30000, 30000, 30000),
    violation = c(2.2, 1.8, 1.2, 0.8),
    lab = c("n = 4,749", "n = 2,990", "n = 389", "n = 722"),
    subject_sex = rep(c("Male", "Female"), 2),
    Grp = factor(rep(c("G2"), 4), levels = c("G1", "G2")))

gg_viols_sex <- viols_sex %>%
    ggplot(aes(x = n/1000, y = violation, fill = subject_sex)) +
    geom_col(width = 0.8, position = "dodge") + hw +
    geom_text(data = sex_labels, aes(label = lab, color = subject_sex),
              size = 5, hjust = 0, fontface = "bold") +
    geom_text(data = ct_labels, aes(label = lab), color = "gray50",
              size = 4, hjust = 0) +
    scale_x_continuous(limits = c(0, 1000)) +
    facet_grid(Grp ~ ., scales = "free_y") +
    labs(x = '# of Police Stops (Thousands)', y = '',
         title = "Males get stopped more than females in Nashville, TN",
         subtitle = "Police Stop Violations from 2010-2018",
         caption = "Source: Stanford Open Policing Project") +
    theme(legend.position = "none",
          axis.text = element_text(size = 12),
          strip.text = element_blank(),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

# gg_viols_sex

ggsave(filename = "../graphics/eda1_violations_sex.png",
       width = 7, height = 7, units = "in")

    # guides(fill = guide_legend(reverse = TRUE)) +
          # legend.position = c(0.8, 0.2),
          # legend.title = element_blank(),
          # legend.text = element_text(size = 11),


## Outcome distribution -------------------------------------------------------
outcome_dist <- stops_10_18 %>%
    count(outcome) %>%
    filter(!is.na(outcome)) %>%
    mutate(outcome = paste0(outcome, "\n(",
                            round(n / sum(n) * 100, 0), "%)"))

gg_outcome_dist <- outcome_dist %>%
    ggplot(aes(x = n/1000, y = reorder(outcome, n))) +
    geom_col(width = 0.7, fill = "blue4") + hw +
    scale_x_continuous(limits = c(0, 2500)) +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(x = '# of Stops (Thousands)', y = '',
         title = "Distribution of Police Stop Outcomes") +
    theme(axis.text = element_text(size = 12),
          plot.title = element_text(size = 14))

gg_outcome_dist




## Outcome types by race -------------------------------------------------------
pop_2018_fn  <- '../input/tn_nashville_2018_censusPop.xlsx'
pop_2018 <- read_excel(pop_2018_fn)


race_out_2018 <- stops_10_18 %>%
    filter(!is.na(outcome)) %>%
    filter(!is.na(subject_race)) %>%
    filter(!subject_race %in% c('unknown', 'other'),
           year == 2018,
           outcome != "summons") %>%
    droplevels() %>%
    select(outcome, subject_race) %>%
    count(outcome, subject_race) %>%
    left_join(pop_2018, by = "subject_race") %>%
    mutate(stops_per_1k = n / race_pop * 1000,
           subject_race = if_else(subject_race == "asian/pacific islander",
                                  "asian*", subject_race),
           race_int_ord = recode(subject_race,
                                 "black" = 4,
                                 "white" = 3,
                                 "hispanic" = 2,
                                 "asian*" = 1)) %>%
    arrange(outcome, race_int_ord)

race_out_2018$outcome  <- factor(race_out_2018$outcome,
                                 levels = c("warning", "citation", "arrest"))

race_out_2018$subject_race <- reorder(race_out_2018$subject_race, -race_out_2018$stops_per_1k)

# color palette from rcolorbrewer
race_out_pal <- brewer.pal(4, "Set1")

# make plot
gg_race_outcome <-
    ggplot(data = race_out_2018,
           mapping = aes(x = stops_per_1k, y = race_int_ord,
                         color = subject_race)) +
    facet_wrap(outcome ~ ., nrow = 3, strip.position = "top",
               scales = "free_x") +
    geom_path(color = "gray50") +
    geom_point(size = 5) +
    geom_point(color = "white", size = 1.5) + hw +
    scale_color_manual(values = race_out_pal) +
    scale_y_continuous(labels = c("black", "white", "hispanic", "asian*"),
                       breaks = c(4, 3, 2, 1),
                       limits = c(0.75, 4.25)) +
    labs(x = 'Stops per 1,000 Persons', y = '',
         title = "2018 Outcomes by Subject Race",
         caption = paste0("Source: Stanford Open Policing Project",
                          "\n*Note: Asian also includes Pacific Islander race")) +
    theme(legend.position = "none",
          axis.text = element_text(size = 12),
          strip.text = element_text(size = 12),
          plot.title = element_text(size = 14))

gg_race_outcome

ggsave(filename = "../graphics/eda2_race_facetOutcome.png",
       width = 7, height = 7, units = "in")


# outcomes by race (race facet)
gg_outcome_race_left <-
    ggplot(data = race_out_2018,
           mapping = aes(x = stops_per_1k, y = reorder(outcome, stops_per_1k),
                         color = subject_race)) +
    facet_wrap(subject_race ~ ., nrow = 4, strip.position = "top") +
    geom_line(aes(group = subject_race)) +
    geom_point(size = 5) +
    geom_point(color = "white", size = 1.5) + hw +
    scale_color_manual(values = race_out_pal) +
    labs(x = 'Stops per 1,000 Persons', y = '',
         title = "2018 Outcomes by Subject Race") +
         # caption = paste0("Source: Stanford Open Policing Project",
         #                  "\n*Note: Asian also includes Pacific Islander race")) +
    theme(legend.position = "none",
          axis.text = element_text(size = 12),
          strip.text = element_text(size = 12),
          plot.title = element_text(size = 14))

gg_outcome_race_left

ggsave(filename = "../graphics/eda2_outcome_facetRace.png",
       width = 7, height = 7, units = "in")

# Juxtaposed outcome by race plots (*in report*)
juxta_plots <- grid.arrange(gg_outcome_race_left, gg_race_outcome, ncol = 2)

ggsave(filename = "../graphics/eda2_outcome_race_juxta.png",
       plot = juxta_plots,
       width = 10, height = 7, units = "in")


## Violations by sex and outcome ----------------------------------------------
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


## 2018 stops by race and day/night -------------------------------------------
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
    mutate(subject_race = if_else(subject_race == "asian/pacific islander",
                                  "asian*", subject_race)) %>%
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
    ggplot(aes(x = stops_per_1k, y = reorder(subject_race, stops_per_1k),
               fill = stopped_daynight)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = night_pchg), hjust = -0.4) +
    scale_fill_manual(values = day_night_colors) + hw +
    scale_x_continuous(limits = c(0, 250)) +
    facet_grid( ~ stopped_daynight) +
    guides(fill = "none") +
    labs(x = "Stops Per 1,000 Persons", y = "",
         title = "Black people are stopped the most at day and night",
         subtitle = "Nashville, TN Police Stops from 2010 to 2018",
         caption = paste0("Source: Stanford Open Policing Project",
                          "\nUS Census Bureau 2019 Population Estimates",
                          "\n\n*Day defined as 7AM - 7:59PM.  All group raw stop counts > 1000.")) +
    theme(axis.text = element_text(size = 11),
          strip.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          plot.subtitle = element_text(face = 'italic'))

# gg_race_time

ggsave(filename = "../graphics/eda4_race_daynight.png",
       width = 8, height = 3, units = "in")

# table(stops_2018$subject_race)
# tail(stops_2018[, c("time", "hour", "stop_night")], 25)

