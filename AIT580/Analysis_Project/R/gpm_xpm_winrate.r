# Q5: Does gold per minute (gpm) or xpm have a higher correlation with a game win?

# AIT 580 Analysis Project

# Doug Cady

# Source: https://medium.com/@conankoh/interpreting-results-from-logistic-regression-in-r-using-titanic-dataset-bb9f9a1f644c

library(readr)
library(dplyr)
# install.packages("ResourceSelection")
library(ResourceSelection)
library(ggplot2)

matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

gpm.xpm.wins <- matches.data %>%
    select(gold.p.min, xp.p.min, win) %>%
    mutate(match.win = if_else(win == 1, 'Won', 'Lost')) %>%
    droplevels()

print(summary(gpm.xpm.wins))


# 5. GPM and XPM correlation with Wins ----------------------------------------
gpm.win.cor <- with(gpm.xpm.wins, cor(gold.p.min, win))
print(gpm.win.cor)  # R = 0.342, R^2 = 0.1169

xpm.win.cor <- with(gpm.xpm.wins, cor(xp.p.min, win))
print(xpm.win.cor)  # R = 0.4471, R^2 = 0.1999

# Logistic regression for GPM
logr.gpm.win.rate <- glm(win ~ gold.p.min,
                         family = 'binomial',
                         data = gpm.xpm.wins)
print(summary(logr.gpm.win.rate))

gpm100.coef <- (exp(coef(logr.gpm.win.rate))['gold.p.min'] - 1) * 100
gpm100.coef # change of winning increases by 0.482% for every 100 gpm increase

deviance(logr.gpm.win.rate)/df.residual(logr.gpm.win.rate)

hoslem.test(gpm.xpm.wins$win, fitted(logr.gpm.win.rate))
# p-value is significant indicating model is Not a good fit of data


## XPM logistic regression
logr.xpm.win.rate <- glm(win ~ xp.p.min,
                         family = 'binomial',
                         data = gpm.xpm.wins)
print(summary(logr.xpm.win.rate))

xpm100.coef <- (exp(coef(logr.xpm.win.rate))['xp.p.min'] - 1) * 100
xpm100.coef # change of winning increases by 0.6728% for every 100 xpm increase

deviance(logr.xpm.win.rate)/df.residual(logr.xpm.win.rate)

hoslem.test(gpm.xpm.wins$win, fitted(logr.xpm.win.rate))
# p-value is significant indicating model is Not a good fit of data


## Wins vs GPM and XPM scatter plot -------------------------------------------
gpm.xpm.plot <- gpm.xpm.wins %>%
    select(-win) %>%
    rename("Gold Per Minute (GPM)" = "gold.p.min",
           "XP Per Minute (XPM)" = "xp.p.min") %>%
    gather("key", "value", -match.win)

gpm.xpm.colors <- c("Gold Per Minute (GPM)" = "#D6AF36", "XP Per Minute (XPM)" = "steelblue3")

gg_wins_gpm_xpm <- gpm.xpm.plot %>%
    ggplot(aes(x = value, y = match.win, color = key)) +
    geom_jitter(alpha = 0.3) +
    facet_wrap( ~ key, nrow = 2) +
    scale_color_manual(values = gpm.xpm.colors) +
    labs(x = '', y = '',
         title = 'GPM and XPM by Match Outcome') +
    theme(legend.position = 'none',
          plot.title = element_text(size = 16),
          strip.text = element_text(size = 12),
          axis.text = element_text(size = 12))

# print(gg_wins_gpm_xpm)
ggsave('../graphics/5_gpm_xpm_cor_win_rate/win_vs_gpm_xpm_scatter.png',
       width = 7, height = 7, units = "in")



# gg_wins_gpm <- gpm.xpm.wins %>%
#     ggplot(aes(x = gold.p.min, y = match.win)) +
#     geom_jitter(color = 'steelblue3', alpha = 0.3) +
#     labs(x = 'Gold per minute (GPM)', y = 'Match outcome',
#          title = 'Investigating correlation between a match win and GPM')

# print(gg_wins_gpm)
# ggsave('../graphics/5_gpm_xpm_cor_win_rate/win_vs_gpm_scatter.png')



## Wins vs XPM scatter plot
# gg_wins_xpm <- gpm.xpm.wins %>%
#     ggplot(aes(x = xp.p.min, y = match.win)) +
#     geom_jitter(color = 'steelblue3', alpha = 0.3) +
#     labs(x = 'XP per minute (XPM)', y = 'Match outcome',
#          title = 'Investigating correlation between a match win and XPM')

# print(gg_wins_xpm)
# ggsave('../graphics/5_gpm_xpm_cor_win_rate/win_vs_xpm_scatter.png')
