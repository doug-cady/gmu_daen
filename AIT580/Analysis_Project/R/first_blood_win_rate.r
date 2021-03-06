# Q4: Does the team that drew first blood (the first game kill) win more often?

# AIT 580 Analysis Project

# Doug Cady


library(readr)
library(dplyr)


matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)


fb.win.rate <- matches.data %>%
    # mutate(team = factor(if_else(isRadiant == TRUE, "Team 1", "Team 2"))) %>%
    group_by(match.id, isRadiant, win) %>%
    summarize(team.first.blood = sum(first.blood)) %>%
    mutate(win.cat = if_else(win == 1, "Won", "Lost"),
           drew.fb = factor(if_else(team.first.blood == 1, "Drew First Blood", "No First Blood")))

summary(fb.win.rate)
# sum(fb.win.rate$team.first.blood)
# length(unique(matches.data$match.id))

fb.win.rate.plot <- fb.win.rate %>%
    ungroup() %>%
    filter(team.first.blood == 1) %>%
    select(win.cat) %>%
    group_by(win.cat) %>%
    count(win.cat) %>%
    rename('match.ct' = 'n')

total.drew.fb <- sum(fb.win.rate.plot$match.ct)


fb.win.rate.simp <- fb.win.rate.plot %>%
    mutate(match.pct = round(match.ct / total.drew.fb * 100, 0))

# print(fb.win.rate.simp)

# 4. Team drawing first blood win rate --------------------------------------
fb.kill.win.cor <- with(fb.win.rate, cor(win, team.first.blood))
print(fb.kill.win.cor)     # R   = 0.1318
print(fb.kill.win.cor**2)  # R^2 = 0.01738

logr.fb.win.rate <- glm(win ~ team.first.blood,
                        family = 'binomial',
                        data = fb.win.rate)

# lm.fb.win.rate <- lm(win ~ team.first.blood, data = fb.win.rate)
print(summary(logr.fb.win.rate))  # R^2 = 0.8444

win.colors <- c("Won" = "steelblue3", "Lost" = "slategray2")

gg_fb_kill_win <- fb.win.rate.simp %>%
    ggplot(aes(x = "", y = match.pct, fill = win.cat)) +
    geom_col(width = 1) +
    coord_polar("y", start = 0) +
    geom_text(aes(label = paste0(win.cat, '\n', match.pct, "%")),
              position = position_stack(vjust = 0.5),
              size = 5) +
    scale_fill_manual(values = win.colors) +
    theme_void() +
    labs(x = '', y = '', fill = '',
         title = 'Pro Dota 2 Teams with a First Blood Kill Win More Often') +
    theme(legend.position = 'none',
          strip.text.x = element_text(size = 12),
          axis.ticks = element_blank(),
          plot.title = element_text(size = 16))

# print(gg_fb_kill_win)
ggsave('../graphics/4_first_blood_win_rate/fb.kill.winrate.png',
       width = 7, height = 7, units = "in")
