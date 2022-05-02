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


pan_desc <- data.frame(
    type = c("mapcum", "id", "bar", "bar", "bar"),
    lab1 = c(NA, NA, "Mean Annual Income",
             "Top 1% Mean", "Bottom 99% Mean"),
    lab2 = c(NA, NA, "Ratio Top 1% to Bot 99%",
             "Annual Income", "Annual Income"),
    col1 = c(NA, NA, 5, 3, 4),
    lab3 = c(NA, NA, "Top 1% / Bot 99%", "Thousands of Dollars ($)",
             "Thousands of Dollars ($)"),
    refVals = c(NA, NA, incomes_no_us[1, 6],
                incomes_no_us[1, 7],
                incomes_no_us[1, 8]),
    refTexts = c(NA, NA, "Mean Ratio", NA, NA)
)

pdf(file = "../graphics/Income_Inequality_Redesign_V1.pdf",
    width = 8.5, height = 11)

micromapST(incomes_no_us, pan_desc,
           rowNamesCol = "state",
           rowNames = "full",
           sortVar = "top_bot_ratio",
           ascend = FALSE,
           title = c("2015 US State Income Inequality - Top 1% vs Bottom 99%")
)
dev.off()
