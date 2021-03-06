# Q1: What is the average number of kills in a Dota 2 game stratified by match duration?
# Q2: What is the distribution of match duration?

# AIT 580 Analysis Project

# Doug Cady


library(readr)
library(dplyr)


matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

fmt.matches <- matches.data %>%
    group_by(match.id, duration.min) %>%
    summarize(total.kills = sum(kills)) %>%
    droplevels()

# Overall mean kills per match
mean.kills.per.match <- mean(fmt.matches$total.kills)
print(mean.kills.per.match)  # 49.65

# 1. Number of kills by match duration ----------------------------------------
duration.levels <- c("<10", "10-19", "20-29", "30-39",
                     "40-49", "50-59", "60-69", "70-79")

kill.duration <- fmt.matches %>%
    mutate(duration.cat = case_when(
               duration.min < 10 ~ "<10",
               duration.min >= 10 & duration.min < 20  ~ "10-19",
               duration.min >= 20 & duration.min < 30  ~ "20-29",
               duration.min >= 30 & duration.min < 40  ~ "30-39",
               duration.min >= 40 & duration.min < 50  ~ "40-49",
               duration.min >= 50 & duration.min < 60  ~ "50-59",
               duration.min >= 60 & duration.min < 70  ~ "60-69",
               duration.min >= 70 & duration.min < 80  ~ "70-79"),
           duration.cat = factor(duration.cat, levels = duration.levels)
    ) %>%
    group_by(duration.cat) %>%
    summarize(mean_kills = mean(total.kills),
              num.matches = n_distinct(match.id))


gg_kill_by_duration <- kill.duration %>%
    ggplot(aes(x = duration.cat, y = mean_kills)) +
    geom_col(fill = 'darkred', width = 0.8) +
    scale_y_continuous(limits = c(0, 80)) +
    geom_text(aes(y = 0, label = paste0('n=', num.matches)), vjust = -0.75) +
    labs(x = '', y = '',
         title = 'Mean Kills per Match by Duration Category (mins)') +
    theme(axis.ticks = element_blank(),
          plot.title = element_text(size = 16),
          axis.text = element_text(size = 12))

# print(gg_kill_by_duration)
ggsave('../graphics/1_mean_kills_by_duration/mean.kills.by.duration.png',
       width = 7, height = 7, units = "in")


# 2. Match duration distribution ----------------------------------------------
# Boxplot distribution
gg_duration_box <- fmt.matches %>%
    ggplot(aes(x = 1, y = duration.min)) +
    geom_boxplot(width = 0.5, alpha = 0.75) +
    scale_y_continuous(limits = c(0, 80)) +
    labs(x = '', y = '',
         title = 'Match Duration (mins) Boxplot (Median = 34.3)') +
    theme(axis.ticks = element_blank(),
          axis.text.x = element_blank(),
          plot.title = element_text(size = 16),
          axis.text = element_text(size = 12))

# print(gg_duration_box)
ggsave('../graphics/2_match_duration_hist/match_duration_box.png',
       width = 7, height = 7, units = "in")


# Histogram distribution
duration.median <- median(fmt.matches$duration.min)

gg_duration_hist <- fmt.matches %>%
    ggplot(aes(x = duration.min)) +
    geom_histogram(fill = 'steelblue3', color = 'gray90', size = 0.25) +
    geom_vline(xintercept = duration.median, linetype = 'dashed') +
    labs(x = '', y = '',
         title = 'Match Duration (mins) Distribution (Median = 34.3)') +
    theme(axis.ticks = element_blank(),
          plot.title = element_text(size = 16),
          axis.text = element_text(size = 12))

# print(gg_duration_hist)
ggsave('../graphics/2_match_duration_hist/match_duration_hist.png',
       width = 7, height = 7, units = "in")



