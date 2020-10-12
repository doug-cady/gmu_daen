# logistic.r
#
# Energy efficiency Data Set
# https://archive.ics.uci.edu/ml/datasets/Energy+efficiency#
#
# Abstract: This study looked into assessing the heating load and
# cooling load requirements of buildings (that is, energy efficiency)
# as a function of building parameters.

# ------------------------------------------------------------------------------
# Logistic regression model
# ------------------------------------------------------------------------------


library(dplyr)
library(readr)
library(magrittr)
library(ggplot2)

# for confusion matrix
library(caret)
library(e1071)


# Get train and test data from linear regression saved data
train <- read_csv("../data/train_ENB2012_data.csv")
test <- read_csv("../data/test_ENB2012_data.csv")


# Transform Cooling Load into a binary response variable
bin_train <- train %>%
    mutate(Low.Cooling.Load = factor(ifelse(Cooling.Load < 25, 1, 0))) %>%
    select(-'Cooling.Load')

bin_test <- test %>%
    mutate(Low.Cooling.Load = factor(ifelse(Cooling.Load < 25, 1, 0))) %>%
    select(-'Cooling.Load')


# Fit logistic regression model
logist_model <- glm(Low.Cooling.Load ~ Surf.Area + Wall.Area + Orient + Glaz.Area,
                    family = 'binomial', data=bin_train)

print(summary(logist_model))

# The results look similar to the linear regression model in that Surf.Area,
# Wall.Area, and Glaz.Area were all significant, while Orient was not.


# Predictions on test data
bin_test$pred <- predict.glm(logist_model, bin_test)

rmse <- function(pred, y) {
    res <- y - pred
    return (sqrt(mean(res^2)))
}

print(paste("RMSE bin_test:", round(rmse(bin_test$pred, bin_test$Low.Cooling.Load), 3)))
# 7.318  - root mean squared error value


# Plot of residuals vs fitted values
residual_gg <- ggplot(data=logist_model) +
    geom_point(aes(x=logist_model$fitted, y=logist_model$residuals),
               color='maroon', shape='X', alpha=0.85) +
    xlab('Fitted') + ylab('Residuals') +
    ggtitle("Residuals vs Fitted values Plot - Logistic Model",
            subtitle="2 big outliers near a fitted value of 0 (circled in blue)") +
    geom_point(aes(x=logist_model$fitted[1], y=logist_model$residuals[1]),
               color='lightblue', shape='O', size=8, alpha=0.75) +
    geom_point(aes(x=logist_model$fitted[2], y=logist_model$residuals[2]),
           color='lightblue', shape='O', size=8, alpha=0.75)
pdf("plots/logist_residual_fitted.pdf")
print(residual_gg)
dev.off()
# There are 2 large residuals (outliers) near fitted value of 0 and I'm not sure why..

# Let's investigate these 2 weird residuals
# print(logist_model$residuals[1:2])
# print(logist_model$fitted[1:2])
# print(bin_test$pred[1:2])
# print(bin_test$Low.Cooling.Load[1:2])
# table(bin_test$Low.Cooling.Load)
# Yeah I'm not sure what's going on with these 2, how they could possibly have
# such different Y and Y_hat values when we're on a binary scale



# Print a confusion matrix to compare our predictions to actual values
print("Confusion Matrix with 0.5 cutoff value")
pihat <- logist_model$fitted.values
classLCL <- factor(ifelse(pihat < 0.5, 0, 1))
print(confusionMatrix(classLCL, bin_train$Low.Cooling.Load, , positive="1"))
# Our prediction accuracy is 98% with a
# Sensitivity (true pos rate) of 97.17%  and
# Specificity (true neg rate) of 99.24% !!
# Wow that is quite impressive!


# Here we test what happens when we lower the cutoff value
# The sensitivity goes up and sensitivity falls (as expected)
print("Confusion Matrix with 0.15 cutoff value")
classLCL.25 <- factor(ifelse(pihat < 0.15, 0, 1))
print(confusionMatrix(classLCL.25, bin_train$Low.Cooling.Load, , positive="1"))


# Plot Low.Cooling.Load - Predicted vs Observed
gg_lin_cool_surf <- ggplot(data=bin_test) +
    geom_point(aes(x=pred, y=Low.Cooling.Load),
               color='maroon', alpha=0.5) +
    geom_abline() +
    xlab('Predicted') + ylab('Observed') +
    ggtitle('Cooling Load - Observed vs Predicted with Logistic Regression')
pdf("plots/logist_y_vs_pred.pdf")
print(gg_lin_cool_surf)
dev.off()
