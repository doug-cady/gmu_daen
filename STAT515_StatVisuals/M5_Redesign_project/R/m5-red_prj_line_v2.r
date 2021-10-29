# Module 5 Redesign Project
# US Average Annual Income Line Plot

library(tidyr)
library(dplyr)
library(ggplot2)
library(readxl)

source("../../R_source_files/hw.R")

data_path <- "../input/"

# US Totals - Average annual income top 1% vs bottom 99% ----------------------
us.avg.incomes.fn <- "us_top-incomes-since-1917_vs2015.xlsx"
us.avg.incomes <- read_excel(file.path(data_path, us.avg.incomes.fn))

us.avg.inc.simp <- us.avg.incomes %>%
    select(Year, "Top 1% (99th–100th percentiles)", "0–99th percentiles") %>%
    rename("Top.1.Perc" = "Top 1% (99th–100th percentiles)",
           "Bot.99.Perc" = "0–99th percentiles")  %>%
    pivot_longer(!Year, names_to = "inc.grp", values_to = "avg.inc")  %>%
    filter(Year >= 1928)  %>%
    mutate(inc.grp = factor(inc.grp),
           year.grp = if_else(Year < 1973, "1928-1973", "1973-2015"))

min.yr <- min(us.avg.inc.simp$Year)
max.yr <- max(us.avg.inc.simp$Year)
year.breaks <- c(seq(min.yr, max.yr, by = 10), max.yr)
med.yr <- median(us.avg.inc.simp$Year)

beg.end.labels <- us.avg.inc.simp %>%
    filter(Year == min.yr | Year == max.yr) %>%
    mutate(avg.inc.lab = if_else(
        avg.inc > 1000000, paste0(round(avg.inc / 1000000, 1), " M"),
            paste0(round(avg.inc / 1000, 1), " K")))
# beg.end.labels

pct.chg.28.73.top1

pct.chg.labels <- us.avg.inc.simp %>%
    filter(Year %in% c(1928, 1973, 2015)) %>%
           # inc.grp == "Top.1.Perc") %>%
    group_by(inc.grp) %>%
    arrange(inc.grp, Year) %>%
    mutate(avg.yr = round((Year + lag(Year)) / 2, 0),
           pct.chg = paste0("\u25B2", round((avg.inc / lag(avg.inc) - 1) * 100, 0), "%"),) %>%
    ungroup() %>%
    filter(Year != 1928)
pct.chg.labels

get_pct_chg <- function(yr, inc.grp.in) {
    return (with(pct.chg.labels,
                           pct.chg.labels[Year == yr & inc.grp == inc.grp.in, ]$pct.chg))
}

pct.chg.28.73.top1 <- get_pct_chg(yr = 1973, inc.grp.in = "Top.1.Perc")
pct.chg.73.15.top1 <- get_pct_chg(yr = 2015, inc.grp.in = "Top.1.Perc")

pct.chg.28.73.bot99 <- get_pct_chg(yr = 1973, inc.grp.in = "Bot.99.Perc")
pct.chg.73.15.bot99 <- get_pct_chg(yr = 2015, inc.grp.in = "Bot.99.Perc")

avg.yr.28.73 <- max(pct.chg.labels[pct.chg.labels$Year == 1973, ]$avg.yr) - 3
avg.yr.73.15 <- max(pct.chg.labels[pct.chg.labels$Year == 2015, ]$avg.yr)

mid.y.yr.28.73 <- 160000
mid.y.yr.73.15 <- 260000

grp.colors <- c("Top.1.Perc" = "#E41A1C",  # red
                "Bot.99.Perc" = "#08519C") # blue
                # "Bot.99.Perc" = "#377EB8")

gg.us.avg.inc.line <- us.avg.inc.simp %>%
    ggplot(aes(x = Year, y = avg.inc, group = inc.grp, color = inc.grp)) +
    geom_line() +

    # End point labels
    geom_text(data = beg.end.labels, aes(label = avg.inc.lab), nudge_y = 50000) +
    geom_point(data = beg.end.labels, aes(x = Year, y = avg.inc, color = inc.grp)) +

    # % Growth labels (1928-1973)
    annotate("text", x = avg.yr.28.73, y = mid.y.yr.28.73 + 70000,
             label = pct.chg.28.73.top1, color = grp.colors["Top.1.Perc"]) +
    annotate("text", x = avg.yr.28.73, y = mid.y.yr.28.73,
             label = "1928 - 1973", color = "gray40") +
    annotate("text", x = avg.yr.28.73, y = mid.y.yr.28.73 - 70000, fontface = "bold",
             label = pct.chg.28.73.bot99, color = grp.colors["Bot.99.Perc"]) +

    # % Growth labels (1973-2015)
    annotate("text", x = avg.yr.73.15, y = mid.y.yr.73.15 + 100000, fontface = "bold",
             label = pct.chg.73.15.top1, color = grp.colors["Top.1.Perc"]) +
    annotate("text", x = avg.yr.73.15, y = mid.y.yr.73.15,
             label = "1973 - 2015", color = "gray40") +
    annotate("text", x = avg.yr.73.15, y = mid.y.yr.73.15 - 100000,
             label = pct.chg.73.15.bot99, color = grp.colors["Bot.99.Perc"]) +
    # geom_text(data = pct.chg.labels,
    #           aes(x = avg.yr, y = avg.inc + 1000,
    #               label = pct.chg, color = inc.grp)) +

    scale_x_continuous(breaks = year.breaks) +
    scale_y_continuous(labels = function(y) {paste0("$", y / 1000000, " M")}) +
    scale_color_manual(values = grp.colors) +

    labs(x = "", y = "",
         title = "US Average Annual Income - Top 1% vs Bottom 99%") +

    annotate("text", x = med.yr - 7, y = 575000, label = "Top 1%",
             color = grp.colors["Top.1.Perc"], size = 6) +
    annotate("text", x = med.yr - 1, y = 90000, label = "Bottom 99%",
             color = grp.colors["Bot.99.Perc"], size = 6) +

    # 1928 dashed Vert line
    # geom_vline(xintercept = 1928, linetype = "dashed", color = "gray50") +
    # annotate("text", x = 1928.5, y = 0, label = "1928",
    #          color = "gray50", vjust = 2.25, hjust = 0, size = 4) +
    # 1973 dashed Vert line
    geom_vline(xintercept = 1973, linetype = "dashed", color = "gray50") +
    annotate("text", x = 1966.5, y = 0, label = "1973",
             color = "gray50", vjust = 2.25, hjust = 0, size = 4) +

    hw +
    theme(legend.position = "none")

print(gg.us.avg.inc.line)

ggsave(filename = "../graphics/us_avg_inc_line.png",
       plot = gg.us.avg.inc.line,
       width = 7, height = 7, units = "in")

    # facet_grid(inc.grp ~ ., scales = "free_y") +


# library(RColorBrewer)
# brewer.pal(n=9, "Blues")
