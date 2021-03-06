# Q3: How does kill/death/assist ratio correlate with experience per minute (xpm)?

# AIT 580 Analysis Project

# Doug Cady


library(readr)
library(dplyr)


matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

kda.xpm <- matches.data %>%
    mutate(kda = if_else(deaths == 0, kills + assists,
                         (kills + assists) / deaths))

# print(summary(kda.xpm))


# 3. Kill/death/assist ratio correlation to XPM -------------------------------
kda.xpm.cor <- with(kda.xpm, cor(kda, xp.p.min))
print(kda.xpm.cor)  # R = 0.5276

lm.kda.xpm <- lm(xp.p.min ~ kda, data = kda.xpm)
r.squared <- round(summary(lm.kda.xpm)$r.squared, 3)
print(summary(lm.kda.xpm))  # R^2 = 0.283

gg_kda_xpm_cor <- kda.xpm %>%
    ggplot(aes(x = kda, y = xp.p.min)) +
    geom_point(alpha = 0.25) +
    geom_smooth(formula = y ~ x, method = 'lm', se = FALSE, size = 0.75) +
    annotate("text", x = 5, y = 1075, label = paste0("italic(R) ^ 2 == ", r.squared), parse = TRUE) +
    labs(x = 'Kill/Death/Assist Ratio (KDA)',
         y = 'Experience per Minute (XPM)',
         title = 'Experience per min (XPM) vs Kill/Death/Assist Ratio (KDA)') +
    theme(axis.ticks = element_blank(),
          plot.title = element_text(size = 16),
          axis.text = element_text(size = 12))

# print(gg_kda_xpm_cor)
ggsave('../graphics/3_kill_death_ratio_cor_xpm/kda.xpm.scatter.png',
       width = 7, height = 7, units = "in")
