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
source("../../R_source_files/hw.R")
source("windows_gui.R")
library(randomForest)

# Load rds data file ----------------------------------------------------------
stops_fn <- "../input/yg821jf8611_tn_nashville_2020_04_01.rds"

stops <- as_tibble(readRDS(stops_fn))


# Data preparation ------------------------------------------------------------
# 2019 only has a few months of stops, so we remove it to focus on full years
# of data from 2010 to 2018

features <- c(
    "year",
    "month",
    "date",
    "time",
    "hour",
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
           month = month(date),
           hour = hour(time)) %>%
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
    dplyr::select(all_of(features))

# summary(stops_10_18)
glimpse(stops_10_18)

# scale
# apply(stops_10_18[, c("subject_age", "subject_race", "subject_sex", "contraband_found")],
#       2, mean)


# Create train and test datasets ----------------------------------------------
set.seed(235)
train_rows <- sample(1:nrow(stops_10_18), nrow(stops_10_18) * 0.7)
train <- stops_10_18[train_rows, ]
test <- stops_10_18[-train_rows, ]

nrow(train)
nrow(test)


# LDA -------------------------------------------------------------------------



fit.lda <- function(fmla, train, test) {
    print(fmla)

    lda.fit <- lda(fmla, data = train)
    print(lda.fit)

    lda.pred <- predict(lda.fit, test)

    print(table(lda.pred$class, test$outcome))
    print(paste0("Test MSE: ", round(mean(lda.pred$class == test$outcome, na.rm=TRUE), 4)))
}

# Model 1 with variables below (test mse: 0.4841)
fmla1 <- outcome ~ subject_age + subject_race + subject_sex + contraband_found
fit.lda(fmla = fmla1, train = train, test = test)

# Model 2 with variables below (test mse: 0.4662)
fmla2 <- outcome ~ time + violation + subject_sex + contraband_drugs
fit.lda(fmla = fmla2, train = train, test = test)

# Model 3 with variables below (test mse: 0.4903)
fmla3 <- outcome ~ subject_race + subject_sex + frisk_performed + contraband_found
fit.lda(fmla = fmla3, train = train, test = test)


# QDA -------------------------------------------------------------------------
# set.seed(235)
# train_rows <- sample(1:nrow(stops_10_18), nrow(stops_10_18) * 0.7)
# train <- stops_10_18[train_rows, ]
# test <- stops_10_18[-train_rows, ]

# nrow(train)
# nrow(test)


fit.qda <- function(fmla, train, test) {
    print(fmla)

    qda.fit <- qda(fmla, data = train)
    print(qda.fit)

    qda.pred <- predict(qda.fit, test)

    print(table(qda.pred$class, test$outcome))
    print(paste0("Test MSE: ", round(mean(lda.pred$class == test$outcome, na.rm=TRUE), 4)))
}

# Model 1 with variables below (test mse: 0.4869)
fmla1 <- outcome ~ subject_age + subject_race + subject_sex + contraband_found
fit.qda(fmla = fmla1, train = train, test = test)

# Model 2 with variables below (test mse: 0.4656) ** lowest MSE of LDA and QDA models **
fmla2 <- outcome ~ time + violation + subject_sex + contraband_drugs
fit.qda(fmla = fmla2, train = train, test = test)

# Model 3 with variables below (test mse: 0.4875)
fmla3 <- outcome ~ subject_race + subject_sex + frisk_performed + contraband_found
fit.qda(fmla = fmla3, train = train, test = test)

# Model 4 with variables below (test mse: 0.4791)
fmla4 <- outcome ~ hour + violation + subject_sex + contraband_found
fit.qda(fmla = fmla4, train = train, test = test)


# Random Forest ---------------------------------------------------------------
fit.RF <- function(data, var_subset) {
    data_subset <- dplyr::select(data, all_of(var_subset)) %>% drop_na()
    set.seed(235)
    rf <- randomForest(outcome ~ ., data = data_subset, ntree = 500,
                       importance = TRUE)
}

# RF model 1 with a subset of 9 predictors and default 2 vars per split, 500 trees
# - OOB estimate error rate: 49.17%
rf.1.features <- c(
    "subject_age", "subject_race", "subject_sex",
    "violation", "contraband_found", "contraband_drugs",
    "contraband_weapons", "frisk_performed", "outcome"
)
rf.1 <- fit.RF(data = train, var_subset = rf.1.features)
rf.1
varImpPlot(rf.1, main = "Model 1 = Police RF Model 8 vars")
# subject_sex seems to be less important


# RF model 2 with a subset of 11 predictors
# - OOB estimate error rate: 45.74%
rf.2.features <- c(
    "year", "month", "time", "subject_age", "subject_race",
    "violation", "contraband_found", "contraband_drugs",
    "contraband_weapons", "frisk_performed", "outcome"
)
rf.2 <- fit.RF(data = train, var_subset = rf.2.features)
rf.2
varImpPlot(rf.2, main = "Model 2 = Police RF Model 10 vars")


# RF model 3 with a subset of 6 predictors
# - OOB estimate error rate: 47.16%
rf.3.features <- c(
    "year", "month", "time", "subject_age", "subject_race",
    "violation", "contraband_found", "outcome"
)
rf.3 <- fit.RF(data = train, var_subset = rf.3.features)
rf.3
varImpPlot(rf.3, main = "Model 3 = Police RF Model 7 vars")


# RF Prototype plot juxtaposed
set.seed(235)
train_small_rows <- sample(1:nrow(stops_10_18), nrow(stops_10_18) * 0.05)
train_small <- stops_10_18[train_small_rows, ] %>%
    mutate(dt_time = as.POSIXct(time, "%H:%M:%S"))

fit.RF.prox <- function(data, var_subset) {
    data_subset <- dplyr::select(data, all_of(var_subset)) %>% drop_na()
    set.seed(235)
    rf <- randomForest(outcome ~ ., data = data_subset, ntree = 500,
                       proximity = TRUE)
}

rf.proto <- fit.RF.prox(data = train_small, var_subset = rf.2.features)
rf.proto

gg_proto_stops <- ggplot(data = train_small,
    aes(x = dt_time, y = subject_age)) +
    geom_hex(bins = 80) + hw +
    labs(x = "Time (24 hour span)", y = "Subject Age (years)",
        title = "Police Stops - Outcome Class Prototypes") +
    facet_wrap(outcome ~ ., nrow = 3, strip.position = "top") +
    scale_x_datetime(date_labels = ("%l %p"),
                     date_breaks = "4 hours") +
    scale_fill_gradient(low = "blue", high = "red") +
    theme(legend.position = "none")

# gg_proto_stops

ggsave(filename = "../graphics/rf_prototype.png",
       plot = gg_proto_stops,
       width = 7, height = 7, units = "in")
