# STAT 515 Redesign Project
# Doug Cady
#

library(readxl)
library(micromapST)
library(dplyr)
library(stringr)


data_path <- "../input/"
data_fn <- "avg_inc_1vs99perc_ratios_2015.xlsx"

# Average annual income top 1% vs bottom 99%
incomes <- as.data.frame(read_excel(file.path(data_path, data_fn)))

incomes_no_us <- incomes %>%
    filter(state != "United States")

repl_comma_dollar_sign <- function(data, repl_col) {
    data[, repl_col] <- gsub(",", "", data[, repl_col])
    data[, repl_col] <- as.numeric(gsub("\\$", "", data[, repl_col])) / 1000
    return(data)
}

incomes_no_us <- repl_comma_dollar_sign(data = incomes_no_us,
                                        repl_col = "avg_inc_top_1per")
incomes_no_us <- repl_comma_dollar_sign(data = incomes_no_us,
                                        repl_col = "avg_inc_bot_99per")

incomes_no_us$mean_ratio <- mean(incomes_no_us$top_bot_ratio)
incomes_no_us$mean_top_1per <- mean(incomes_no_us$avg_inc_top_1per)
incomes_no_us$mean_bot_99per <- mean(incomes_no_us$avg_inc_bot_99per)

glimpse(incomes_no_us)


# Top 1% Share of all Income by US state over time
top_income_fn <- "top_1per_income_over_time.xlsx"
top_incomes <- as.data.frame(read_excel((file.path(data_path, top_income_fn))))

top_incomes <- top_incomes %>%
    select(state, "1973", "2015", "1973-2015") %>%
    filter(state != "United States")

repl_quote_percent_sign <- function(data, repl_col) {
    data[, repl_col] <- gsub('"', "", data[, repl_col])
    data[, repl_col] <- as.numeric(gsub("%", "", data[, repl_col]))
    return(data)
}

fmt_top_incomes <- repl_quote_percent_sign(data = top_incomes,
                                           repl_col = "1973")
fmt_top_incomes <- repl_quote_percent_sign(data = fmt_top_incomes,
                                           repl_col = "2015")

glimpse(fmt_top_incomes)


merged_incomes <- left_join(incomes_no_us, fmt_top_incomes) %>%
    select(state, top_bot_ratio, mean_ratio, "1973", "2015", "1973-2015") %>%
    rename(inc_share_1973 = "1973",
           inc_share_2015 = "2015",
           per_chg_73_15 = "1973-2015")

glimpse(merged_incomes)


pan_desc <- data.frame(
    type = c("mapcum", "id", "dot", "arrow", "bar"),

    lab1 = c(NA, NA, "Mean Annual Income", "Top 1% Share of All Income",
             "Percent Change"),
    lab2 = c(NA, NA, "Ratio Top 1% to Bot 99%", "1973 - 2015",
             "1973 - 2015"),

    col1 = c(NA, NA, "top_bot_ratio", "inc_share_1973", "per_chg_73_15"),
    col2 = c(NA, NA, NA, "inc_share_2015", NA),

    lab3 = c(NA, NA, "Top 1% / Bot 99%", "Percent", "Percent"),

    refVals = c(NA, NA, incomes_no_us[1, "mean_ratio"], NA, NA),
    refTexts = c(NA, NA, "Mean Ratio", NA, NA)
)

pdf(file = "../graphics/Income_Inequality_Redesign_V2.pdf",
    width = 8.5, height = 11)

micromapST(merged_incomes, pan_desc,
           rowNamesCol = "state",
           rowNames = "full",
           sortVar = "top_bot_ratio",
           ascend = FALSE,
           title = c("2015 US State Income Inequality - Top 1% vs Bottom 99%")
)
dev.off()
