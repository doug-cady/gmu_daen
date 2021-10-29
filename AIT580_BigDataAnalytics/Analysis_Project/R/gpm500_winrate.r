# Q6: Do players with 500 or more gpm win games more often than those with less than 500 gpm?

# AIT 580 Analysis Project

# Doug Cady


library(readr)
library(dplyr)
library(car)
library(qqplotr)
# library(ResourceSelection)

matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

gpm.gte.500.wins <- matches.data %>%
    select(gold.p.min, win) %>%
    mutate(gpm.gte.500 = if_else(gold.p.min >= 500, 1, 0),
           gpm.gte.500.chr = if_else(gold.p.min >= 500, ">=500", "<500"),
           win.cat = if_else(win == 1, "win", "loss")) %>%
    droplevels()

print(summary(gpm.gte.500.wins))

print(table(gpm.gte.500.wins$win.cat, gpm.gte.500.wins$gpm.gte.500.chr))


# 6.1 GPM 500+ correlation with match wins -------------------------------------
gpm.gte.500.win.cor <- with(gpm.gte.500.wins, cor(gpm.gte.500, win))
print(gpm.gte.500.win.cor)  # R = 0.2597
print(gpm.gte.500.win.cor**2) # R^2 = 0.06744


# Logistic regression for GPM >= 500
logr.gpm.win.rate <- glm(win ~ gpm.gte.500,
                         family = 'binomial',
                         data = gpm.gte.500.wins)
print(summary(logr.gpm.win.rate))

deviance(logr.gpm.win.rate)/df.residual(logr.gpm.win.rate)

hoslem.test(gpm.gte.500.wins$win, fitted(logr.gpm.win.rate))
# p-value is Not significant indicating model is a good fit of data


# 6.2 Do winning teams have a significant difference in median team GPM? ------
# (hypothesis testing)

win.groups <- matches.data %>%
    select(match.id, isRadiant, win, gold.p.min) %>%
    mutate(win.cat = factor(if_else(win == 1, "Won", "Lost")),
           team = factor(if_else(isRadiant == TRUE, "Team 1", "Team 2"))) %>%
    group_by(match.id, team, win.cat) %>%
    summarize(median.team.gpm = median(gold.p.min)) %>%
    ungroup() %>%
    select(win.cat, median.team.gpm) %>%
    droplevels()

## 6.2.1 Shapiro-Wilk test for normality on each group (fails)
win.groups %>%
    group_by(win.cat) %>%
    summarize('W.Stat' = shapiro.test(median.team.gpm)$statistic,
              'p.val' = shapiro.test(median.team.gpm)$p.value)


## 6.2.2 test assumptions of normality of 2 groups using QQ plot
gg_qqplot <- win.groups %>%
    ggplot(aes(sample = median.team.gpm, color = win.cat, fill = win.cat)) +
    stat_qq_band(alpha = 0.5, conf = 0.95, qtype = 1, bandType = 'ts') +
    stat_qq_line(identity = TRUE) +
    stat_qq_point(col = "black") +
    facet_wrap( ~ win.cat, scales = "free", nrow = 1) +
    labs(x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_bw() +
    theme(legend.position = 'none')

# print(gg_qqplot)
ggsave('../graphics/6_500gpm_win_rate/qq_plot.png',
       width = 7, height = 7, units = "in")


## Distribution of both groups
gg_win_gpm_hist <- win.groups %>%
    ggplot(aes(x = median.team.gpm, fill = win.cat)) +
    geom_density(alpha = 0.75)

# print(gg_win_gpm_hist)
ggsave('../graphics/6_500gpm_win_rate/dist_2grps.png',
       width = 7, height = 7, units = "in")


## Perform Wilcoxon Rank Sum Test
wilcox.res <- wilcox.test(median.team.gpm ~ win.cat, data = win.groups,
                          conf.int = TRUE)
print(wilcox.res)

## From QQ plot
# qqnorm(win.groups$median.team.gpm, pch = 1, frame = FALSE)
# qqline(win.groups$median.team.gpm, col = 'steelblue3', lwd = 2)


## 6.2.2 test assumption of equality of variance with F-test
## - p-value = 1, thus the variances of the two groups is equal.
# print(var.test(median.team.gpm ~ arena.side, win.groups, alternative = 'two.sided'))


