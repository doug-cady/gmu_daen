# Energy efficiency Data Set
# https://archive.ics.uci.edu/ml/datasets/Energy+efficiency#
#
# Abstract: This study looked into assessing the heating load and
# cooling load requirements of buildings (that is, energy efficiency)
# as a function of building parameters.

# ***********************************************************************
# My understanding of the resources allowed include:
# - my own zybooks exercises (course text)
# - completed datacamp courses where I wrote the code being referenced
#
# If this is not the case, then I probably messed up here doing
# more than was asked for..
# ***********************************************************************


# ------------------------------------------------------------------------------
# Lienar regression model
# ------------------------------------------------------------------------------


library(dplyr)
library(readxl)
library(readr)
library(magrittr)
library(ggplot2)


col_names <- c(
    'Rel.Compact',
    'Surf.Area',
    'Wall.Area',
    'Roof.Area',
    'Ovr.Height',
    'Orient',
    'Glaz.Area',
    'Glaz.Area.Dist',
    'Heating.Load',
    'Cooling.Load')

# Load excel file into data.frame
data <- read_excel("../data/ENB2012_data.xlsx",
                   col_names = col_names,
                   col_types = 'numeric',
                   skip = 1)  # first row of data is NAs


# Explore data structure and quartiles
print(summary(data))

# We can see from summary that some columns are not on the same scale (like
# Rel.Compact 0.98 max vs Surf.Area 808.5 max)

# We will need to standardize the data before performing any
# type of regression



# Standardization - calculates a Z-score for each value
# Z = (x - mean_x) / sd_x
# This moves every feature to have a mean of 0 and sd of 1
means <- unlist(lapply(data, mean, na.rm=TRUE))
sds <- unlist(lapply(data, sd, na.rm=TRUE))

stand_data <- select(data, -Heating.Load)

# Standardize all features, but not response variable
cols_to_standardize <- names(select(stand_data, -Cooling.Load))

for (col in cols_to_standardize) {
    stand_data[ ,col] <- (data[ ,col] - means[col]) / sds[col]
}

# Check out new standardized data
print(summary(stand_data))


# Check correlations in predictor variables
print(round(cor(select(stand_data, -Cooling.Load)), 4))
# Okay none of these predictors are highly correlated and would need
# to be collapsed into one variable

# We can also visualize the correlation of each predictor variable
pdf("plots/correlation_matrix.pdf")
pairs(select(stand_data, -Cooling.Load))
dev.off()


# Split into train and test data
set.seed(473)
uni_rand_var <- runif(nrow(stand_data))
train_test_ratio <- 0.7

train <- stand_data[uni_rand_var < train_test_ratio, ]
test <- stand_data[uni_rand_var >= train_test_ratio, ]

# Train, test split by row count
print(paste("Train rows:", nrow(train)))
print(paste("Test rows:", nrow(test)))


# Select features to use in this regression
model_cols <- c(
    'Surf.Area',
    'Wall.Area',
    'Orient',
    'Glaz.Area',
    'Cooling.Load')

simp_train <- train %>%
    select(model_cols)

simp_test <- test %>%
    select(model_cols)


# Save data for use in logistic model in other program
write_csv(simp_train, "../data/train_ENB2012_data.csv")
write_csv(simp_test, "../data/test_ENB2012_data.csv")


# We can see from the initial summary of data that Cooling.Load is a continuous response variable,
# which is why we chose to do a linear regression instead of logistic.
# Let's check if Cooling.Load is normally distributed (one assumption of linear regression)
hist_resp <- ggplot(data = simp_train) +
    geom_histogram(aes(x=Cooling.Load),
                   color='white', fill='maroon') +
    ggtitle("Histogram of response variable - Cooling.Load",
            subtitle="Distribution is bimodal, not normal")
pdf("plots/hist_cooling_load.pdf")
print(hist_resp)
dev.off()
# Spoiler: I think it's bimodal instead of normally distributed.  Maybe we need
# to transform it using a log response instead of straight up.

hist_log_resp <- ggplot(data = simp_train) +
    geom_histogram(aes(x=log(Cooling.Load)),
                   color='white', fill='maroon') +
    ggtitle("Histogram of Log response variable - Cooling.Load",
            subtitle="Distribution is bimodal, not normal")
pdf("plots/hist_log_cooling_load.pdf")
print(hist_log_resp)
dev.off()
# But the log response doesn't look any better.  Without consulting other resources,
# this is the best I can do here to tackle the normality of the response variable -
# to point out that it's not normal.




# Fit multiple linear regression model
lm_model <- lm(Cooling.Load ~ Surf.Area + Wall.Area + Orient + Glaz.Area, data=simp_train)

print(summary(lm_model))

# Looking at the results, we can see a very small p-value for our overall F-test (last row)
# which indicates that a significant linear relationship exists between our response
# and predictor variables.  This is a good sign that this data does not violate the linear
# regression assumptions.

# Also, there are multiple highly statistically significant predictors here (<.0001) - namely
# Surf.Area, Wall.Area, and Glaz.Area - whereas Orient was not significant in predicting Cooling.Load.
# From the coefficients, we can see that Wall.Area and Glaz.Area had a positive relationship
# to the response Cooling.Load, while Surf.Area's relationship was negative.
# The overall R^2 value is 0.86 which is fantastic and means that the model was able to explain
# about 86% of the variance in the data


# Predictions on test data
simp_test$pred <- predict(lm_model, simp_test)

rmse <- function(pred, y) {
    res <- y - pred
    return (sqrt(mean(res^2)))
}

print(paste("RMSE test:", round(rmse(simp_test$pred, simp_test$Cooling.Load), 3)))
# 3.909  - root mean squared error value


# Plot of residuals vs fitted values
residual_gg <- ggplot(data=lm_model) +
    geom_point(aes(x=lm_model$fitted, y=lm_model$residuals),
               color='maroon', alpha=0.75) +
    geom_hline(yintercept=0, size=0.25, alpha=0.75) +
    geom_abline(slope=0.75, intercept=-6.5, size=0.3,
                linetype='dashed', color='blue', alpha=0.3) +
    geom_abline(slope=-0.5, intercept=4.5, size=0.3,
                linetype='dashed', color='blue', alpha=0.3) +
    xlab('') + ylab('') + ggtitle("Residuals vs Fitted value Plot - Linear Model",
                                  subtitle="Slight funnel shape going left to right (violates constant variance assumption)")
pdf("plots/lm_residual_fitted.pdf")
print(residual_gg)
dev.off()
# This plot seems to violate consant variance assumption; there is a funnel pattern getting
# wider as the fitted values increase!  That's not great!


# Plot Cooling.Load - Predicted vs Observed
coefs <- round(lm_model$coefficients, 3)
Y_hat_eqn <- paste0("Y_hat = ", coefs['(Intercept)'],
                    " - ", abs(coefs['Surf.Area']), " * Surf.Area",
                    " + ", coefs['Wall.Area'], " * Wall")
Y_hat_eqn2 <- paste0(" + ", coefs['Orient'], " * Orient",
                    " + ", coefs['Glaz.Area'], " * Glaz.Area")

gg_lin_cool_surf <- ggplot(data=simp_test) +
    geom_point(aes(x=pred, y=Cooling.Load), color='maroon') +
    geom_abline(alpha=0.75) +
    annotate("text", x=19, y=45.65, label=Y_hat_eqn) +
    annotate("text", x=16.5, y=44.5, label=Y_hat_eqn2) +
    xlab('Predicted') + ylab('Observed') +
    ggtitle('Cooling Load - Observed vs Predicted with Linear Regression')
pdf("plots/lm_y_vs_pred.pdf")
print(gg_lin_cool_surf)
dev.off()

