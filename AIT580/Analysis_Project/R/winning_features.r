# Q7: What features lead to an edge in winning (> 50% accuracy)?

# AIT 580 Analysis Project

# Doug Cady


library(readr)
library(dplyr)
library(psych)
library(ResourceSelection)
library(ggplot2)
library(car)

# for confusion matrix
library(caret)
library(e1071)
# install.packages(c("caret", "e1071"))


matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

# print(summary(matches.data))

duration.levels <- c("<10", "10-19", "20-29", "30-39",
                     "40-49", "50-59", "60-69", "70-79")

# Aggregate individual player data to team level
team.data <- matches.data %>%
    group_by(match.id, isRadiant, win) %>%
    rename(target.win = win) %>%
    summarize(drew.fb = sum(first.blood),
              kills = sum(kills),
              deaths = sum(deaths),
              assists = sum(assists),
              hero.dmg = sum(hero.dmg),
              hero.heal = sum(hero.heal),
              last.hits = sum(last.hits),
              denies = sum(denies),
              tower.dmg = sum(tower.dmg),
              runes = sum(runes),
              obs.set = sum(obs.set),
              stuns = sum(stuns)
    ) %>%
    ungroup() %>%
    select(target.win:stuns) %>%
    mutate(tower.dmg.1k = tower.dmg / 1000)
           # target.win = factor(target.win))


# Split into train and test data
set.seed(470)
uni_rand_var <- runif(nrow(team.data))
train_test_ratio <- 0.7

train <- team.data[uni_rand_var < train_test_ratio, ]
test <- team.data[uni_rand_var >= train_test_ratio, ]

# Train, test split by row count
print(paste("Train rows:", nrow(train)))
print(paste("Test rows:", nrow(test)))

# Summary data for train dataset
summary(train)


# Correlation matrix for this data subset
# corPlot(train, cex = 1.05,
#         diag = FALSE, scale = FALSE,
#         main = 'Pro Dota 2 Match Feature Correlation Matrix (V1)')

# Simplify feature set for later model building
simp.train <- train %>%
    select(target.win, assists, deaths, tower.dmg.1k, runes)

# corPlot(simp.train, cex = 1.15,
#         diag = FALSE, scale = FALSE,
#         main = 'Dota 2 Match Feature Correlation Matrix (V2)')


pairs.plot <- function(data, marker, add_jitter) {
    return (pairs.panels(data,
                         smooth = TRUE,
                         scale = FALSE,
                         density = TRUE,
                         ellipses = FALSE,
                         method = 'pearson',
                         pch = marker,
                         lm = TRUE,
                         cor = TRUE,
                         jiggle = add_jitter,
                         factor = 3,
                         hist.col = 4,
                         stars = FALSE,
                         ci = FALSE))
}

# print(pairs.plot(data = simp.train,
#                  marker = 21,
#                  add_jitter = TRUE))


## Univariate logistic regression with predictor tower.dmg.1k -----------------
log.res.uni <- glm(data = simp.train,
                   formula = target.win ~ tower.dmg.1k,
                   family = 'binomial')

summary(log.res.uni)

# Exponentiate model results to interpret coeffient meanings
exp(coef(log.res.uni))
exp(confint(log.res.uni))

hoslem.test(simp.train$target.win, fitted(log.res.uni))

# Predictions on test data
# test$pred.uni <- predict.glm(log.res.uni, test)

# Investigate overdispersion - if ratio >> 1, then overdispersion issue
# ratio = 0.65, no issue
deviance(log.res.uni)/df.residual(log.res.uni)

# Plot of residuals vs fitted values
gg_residual_uni <- log.res.uni %>%
    ggplot(aes(x = log.res.uni$fitted, y = log.res.uni$residuals)) +
    geom_point(color='maroon', shape='X', alpha=0.85) +
    labs(x = 'Fitted', y = 'Residuals',
         title = "Residuals vs Fitted values Plot - Univariate Logistic Model")
         #subtitle="asdf")
    # geom_point(aes(x=log.res.uni$fitted[1], y=log.res.uni$residuals[1]),
    #            color='lightblue', shape='O', size=8, alpha=0.75) +
    # geom_point(aes(x=log.res.uni$fitted[2], y=log.res.uni$residuals[2]),
    #            color='lightblue', shape='O', size=8, alpha=0.75)
print(gg_residual_uni)



# Multivariate logistic regression model --------------------------------------
log.model <- glm(data = simp.train,
                 formula = target.win ~ assists + deaths + tower.dmg.1k + runes,
                 # formula = target.win ~ drew.fb + I(deaths^0.5) + tower.dmg + I(kill.assist^0.5),
                 family = 'binomial')

summary(log.model)

# Exponentiate model results to interpret coeffient meanings
exp(coef(log.model))
exp(confint(log.model))

hoslem.test(simp.train$target.win, fitted(log.model))


# Predictions on test data
# test$pred.multi <- predict.glm(log.model, test)

# Investigate overdispersion - if ratio >> 1, then overdispersion issue
# ratio = 0.22, no issue
deviance(log.model)/df.residual(log.model)


# Plot of residuals vs fitted values
gg_residual_multi <- log.model %>%
    ggplot(aes(x = log.model$fitted, y = log.model$residuals)) +
    geom_point(color='maroon', shape='X', alpha=0.85) +
    labs(x = 'Fitted', y = 'Residuals',
         title = "Residuals vs Fitted values Plot - Logistic Model",
         subtitle="asdf")
    # geom_point(aes(x=log.model$fitted[1], y=log.model$residuals[1]),
    #            color='lightblue', shape='O', size=8, alpha=0.75) +
    # geom_point(aes(x=log.model$fitted[2], y=log.model$residuals[2]),
    #            color='lightblue', shape='O', size=8, alpha=0.75)
# print(gg_residual_multi)
ggsave('../graphics/7_win_rate_features/gg_residuals.png',
       width = 7, height = 7, units = "in")

# Pearson residuals (lack-of-fit test)
init.fmla <- target.win ~ assists + deaths + tower.dmg.1k + runes
residualPlots(log.model)

# deaths variable is significant in Pearson residuals lack-of-fit test
# indicating to add squared deaths term as well
mod2.fmla <- target.win ~ assists + I(assists^2) + deaths + I(deaths^2) + tower.dmg.1k + runes

log.mod2 <- glm(data = simp.train,
                formula = mod2.fmla,
                # formula = target.win ~ assists + I(assists^2)
                #   + deaths + I(deaths^2)
                #   + tower.dmg.1k + runes,
                family = 'binomial')

residualPlots(log.mod2)


# Final Iteration of Model below ----------------------------------------------
# deaths and tower.dmg.1k variable are significant in Pearson residuals
# lack-of-fit test indicating to add these 2 squared terms as well
mod3.fmla <- target.win ~ assists + I(assists^2) +
    deaths + I(deaths^2) + I(deaths^3) +
    tower.dmg.1k + I(tower.dmg.1k^2) + runes

log.mod3 <- glm(data = simp.train,
                formula = mod3.fmla,
                # formula = target.win ~ assists + I(assists^2)
                #   + deaths + I(deaths^2) + I(deaths^4)
                #   + tower.dmg.1k + I(tower.dmg.1k^2) + runes,
                family = 'binomial')

residualPlots(log.mod3)


# Marginal model plots to check model fit
# Response variable vs expalantory variable for each exp var
marginalModelPlots(log.mod3)

# Outlier test using studentized residuals
outlierTest(log.mod3, cutoff = 0.05, n.max = 20)

# Model is good fit for data
hoslem.test(simp.train$target.win, fitted(log.mod3))



# Final results of V3 model
summary(log.mod3)
exp(coef(log.mod3))
exp(confint(log.mod3))


# Test final model on 'test' data ---------------------------------------------
test$pred <- predict.glm(log.mod3, test)

simp.train.fac <- simp.train %>%
    mutate(target.win = factor(target.win))

## Confusion matrix to show correct and incorrect predictions
pihat <- log.mod3$fitted.values
cutoff.val <- 0.5
match.Win <- factor(ifelse(pihat < cutoff.val, 0, 1))
print(confusionMatrix(match.Win, simp.train.fac$target.win, , positive="1"))


## Final visual showing predictions versus observed wins
# Plot Low.Cooling.Load - Predicted vs Observed
gg_log_mod3_y_vs_pred <- test %>%
    ggplot(aes(x = pred, y = target.win)) +
    geom_point(color = 'maroon', alpha = 0.4) +
    geom_abline() +
    labs(x = 'Predicted', y = 'Observed',
         title = 'Match Outcome - Observed vs Predicted with Logistic Regression')

# print(gg_log_mod3_y_vs_pred)
ggsave('../graphics/7_win_rate_features/log_mod3_y_vs_pred.png',
       width = 7, height = 7, units = "in")


###  calculating model probabilities by plugging in predictor
###  values and finding probability result
0.36816 + 0.07652*4 - 0.27757*0 + 0.29320*5 - 0.05036*1  # = 2.09
0.36816 + 0.07652*10 - 0.27757*11 + 0.29320*7.234 - 0.05036*4 # -0.0003615

test.1 <- data.frame(
    "assists" = c(10),
    "deaths" = c(11),
    "tower.dmg.1k" = c(7.234),
    "runes" = c(4))

exp(predict(log.model, test.1))

OR <- exp(-0.0003615)
prob <- OR/(OR + 1)
prob



# log.model[log.model$residuals < -1000]

# influenceIndexPlot(log.mod3, id.n = 3)

# print(influencePlot(log.model, id.n = 3))
