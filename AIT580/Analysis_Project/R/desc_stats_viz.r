# Descriptive stats and viz

# AIT 580 Analysis Project

# Doug Cady

library(readr)
library(dplyr)
library(tidyr)
library(ResourceSelection)
library(psych) # correlation matrix plot
library(ggplot2)

matches.fn <- '../output/match_player_data_v2.tsv'
matches.data <- read_tsv(matches.fn)

simp.matches <- matches.data %>%
    select(match.id,
           player.slot,
           duration.min,
           radiant.win,
           isRadiant,
           win,
           kills,
           deaths,
           assists,
           gold.p.min,
           xp.p.min,
           hero.dmg,
           hero.heal,
           last.hits,
           denies,
           tower.dmg,
           runes,
           obs.set,
           stuns,
           first.blood,
           match.kills) %>%
    mutate(win = as.logical(win),
           match.win = factor(if_else(win == 1, 'Won', 'Lost'))) %>%
    droplevels()

# 1. Summary stats
print(summary(simp.matches))


# 2. Histograms of selected columns
quant.data <- simp.matches %>%
    select(-match.id, -player.slot, -isRadiant, -radiant.win, -match.win)

hist.data <- quant.data %>%
    select(-first.blood, -win)

add.comma.thous <- function(x){
    return (if_else(x > 1000, paste0(x / 1000, 'k'), paste(x)))
}

gg_hist_cols <- gather(hist.data) %>%
    ggplot(aes(value)) +
    geom_histogram(bins = 15, fill = 'steelblue3') +
    labs(x = '', y = '',
         title = 'Histograms for Selected Dataset Columns') +
    facet_wrap( ~ key, scales = 'free_x') +
    scale_x_continuous(labels = function(x) {add.comma.thous(x)}) +
    theme(axis.text = element_text(size = 11),
          plot.title = element_text(size = 14),
          strip.text = element_text(size = 12))

# print(gg_hist_cols)
ggsave('../graphics/0_desc_viz/hist_cols.png', width = 7, height = 7, units = "in")


# 4. Boxplots of a few columns with similar scales
box.data <- hist.data %>%
    select(kills, deaths, assists, denies, runes)

gg_box <- gather(box.data) %>%
    ggplot(aes(x = key, y = value)) +
    geom_boxplot(alpha = 0.5) +
    labs(x = '', y = '',
         title = 'Boxplot Distribution for Key Match Statistics') +
    theme(axis.text = element_text(size = 12),
          plot.title = element_text(size = 14))

# print(gg_box)
ggsave('../graphics/0_desc_viz/boxplots.png', width = 7, height = 7, units = "in")


# 4. Pairwise correlation matrix
dota2.cor.matrix <- corPlot(quant.data, cex = 1.0,
                            diag = FALSE, scale = FALSE, xlas = 1,
                            main = 'Dota 2 Match Data Correlation Matrix')

# print(dota2.cor.matrix)



# Descriptive viz
