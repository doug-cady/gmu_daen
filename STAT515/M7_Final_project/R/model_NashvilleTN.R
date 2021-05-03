# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219

# Part 2: Linear Discriminant Analysis (LDA),
#         Quadratic Disrciminant Analysis (QDA),
#     and Random Forest Modeling (RF)
# -----------------------------------------------------------------------------


library(dplyr)
library(tidyr)
library(readr)
library(readxl) # excel files
library(ggplot2)
library(lubridate) # date/time functions
library(MASS) # LDA, QDA
library(randomForest)
source("windows_gui.R")
source("../../R_source_files/hw.R")

# Load rds data file ----------------------------------------------------------
stops_fn <- "../input/yg821jf8611_tn_nashville_2020_04_01.rds"

stops <- as_tibble(readRDS(stops_fn))


# Data preparation ------------------------------------------------------------
# 2019 only has a few months of stops, so we remove it to focus on full years
# of data from 2010 to 2018

features <- c(
    "year",
    "month",
    "time",
    "lat",
    "lng",
    "precinct",
    "reporting_area",
    "zone",
    "subject_age",
    "subject_race",
    "subject_sex",
    "violation",
    "contraband_found",
    "contraband_drugs",
    "contraband_weapons",
    "frisk_performed",
    # "search_conducted",
    # "search_person",
    # "search_vehicle",
    # "search_basis",
    "outcome"
)

stops_10_18 <- stops %>%
    mutate(year = year(date),
           month = month(date)) %>%
    filter(year < 2019,
           outcome != 'summons',
           !subject_race %in% c('unknown', 'other')) %>%
    filter(!is.na(subject_race)) %>%
    filter(!is.na(subject_sex)) %>%
    filter(!is.na(violation)) %>%
    filter(!is.na(outcome)) %>%
    filter(!is.na(time)) %>%
    mutate(hour = hour(time),
           precinct = factor(precinct),
           reporting_area = factor(reporting_area),
           zone = factor(zone),
           subject_race = factor(subject_race),
           subject_sex = factor(subject_sex),
           outcome = factor(outcome)) %>%
    # Narrow feature set a bit removing raw columns
    dplyr::select(features)

# summary(stops_10_18)
glimpse(stops_10_18)

# scale
# apply(stops_10_18[, c("subject_age", "subject_race", "subject_sex", "contraband_found")],
#       2, mean)


# LDA -------------------------------------------------------------------------
set.seed(235)
train_rows <- sample(1:nrow(stops_10_18), nrow(stops_10_18) * 0.7)
train <- stops_10_18[train_rows, ]
test <- stops_10_18[-train_rows, ]

nrow(train)
nrow(test)


fit.lda <- function(fmla, train, test) {
    lda.fit <- lda(fmla, data = train)
    print(lda.fit)

    lda.pred <- predict(lda.fit, test)

    print(table(lda.pred$class, test$outcome))
    print(mean(lda.pred$class == test$outcome, na.rm=TRUE))
}

# Model 1 with variables below (mean 0.4841)
fmla1 <- outcome ~ subject_age + subject_race + subject_sex + contraband_found
fit.lda(fmla1, train, test)

# Model 2 with variables below (mean 0.4662)
fmla2 <- outcome ~ time + violation + subject_sex + contraband_drugs
fit.lda(fmla2, train, test)

# Model 3 with variables below (mean 0.4903)
fmla3 <- outcome ~ subject_race + subject_sex + frisk_performed + contraband_found
fit.lda(fmla3, train, test)


# QDA -------------------------------------------------------------------------
# set.seed(235)
# train_rows <- sample(1:nrow(stops_10_18), nrow(stops_10_18) * 0.7)
# train <- stops_10_18[train_rows, ]
# test <- stops_10_18[-train_rows, ]

# nrow(train)
# nrow(test)


fit.qda <- function(fmla, train, test) {
    qda.fit <- qda(fmla, data = train)
    print(qda.fit)

    qda.pred <- predict(qda.fit, test)

    print(table(qda.pred$class, test$outcome))
    print(mean(qda.pred$class == test$outcome, na.rm=TRUE))
}

# Model 1 with variables below (mean 0.4869)
fmla1 <- outcome ~ subject_age + subject_race + subject_sex + contraband_found
fit.qda(fmla1, train, test)

# Model 2 with variables below (mean 0.4656)
fmla2 <- outcome ~ time + violation + subject_sex + contraband_drugs
fit.qda(fmla2, train, test)

# Model 3 with variables below (mean 0.4875)
fmla3 <- outcome ~ subject_race + subject_sex + frisk_performed + contraband_found
fit.qda(fmla3, train, test)


# Random Forest ---------------------------------------------------------------

fit.RF <- function(data, var_subset) {
    data_subset <- dplyr::select(data, all_of(var_subset)) %>% drop_na()
    set.seed(235)
    rf <- randomForest(outcome ~ ., data = data_subset, importance = TRUE)
}

# RF model 1 with a subset of 9 predictors and default 2 vars per split, 500 trees
# - OOB estimate error rate: 49.17%
rf.1.features <- c(
    "subject_age", "subject_race", "subject_sex",
    "violation", "contraband_found", "contraband_drugs",
    "contraband_weapons", "frisk_performed", "outcome"
)
rf.1 <- fit.RF(data = stops_10_18, var_subset = rf.1.features)
rf.1
varImpPlot(rf.1, main = "Model 1 = Police RF Model 9 vars")
# subject_sex seems to be less important


# RF model 2 with a subset of 11 predictors
# - OOB estimate error rate: 45.74%
rf.2.features <- c(
    "year", "month", "time", "subject_age", "subject_race",
    "violation", "contraband_found", "contraband_drugs",
    "contraband_weapons", "frisk_performed", "outcome"
)
rf.2 <- fit.RF(data = stops_10_18, var_subset = rf.2.features)
rf.2
varImpPlot(rf.2, main = "Model 2 = Police RF Model 11 vars")


# RF model 3 with a subset of 6 predictors
# - OOB estimate error rate: 47.16%
rf.3.features <- c(
    "year", "month", "time", "subject_age", "subject_race",
    "violation", "contraband_found", "outcome"
)
rf.3 <- fit.RF(data = stops_10_18, var_subset = rf.3.features)
rf.3
varImpPlot(rf.3, main = "Model 3 = Police RF Model 6 vars")
