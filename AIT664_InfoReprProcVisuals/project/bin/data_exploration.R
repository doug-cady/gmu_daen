# Initial data exploration for AIT 664 data visualization project
# on Human Freedom Index and suicide rates

# Doug Cady
# Nov. 6, 2021

# R version 4.1.1 "Kick Things"


# Questions to explore: ----------------------------------------------------------------------------
# 1) If a country's freedom score, number of suicides / 100k, and gdp per capita are related
#  > correlation, scatter plot x 3
# 2) Does a country's population impact freedom? correlation here?
# 3) Does a country's female freedom scores relate to its female suicide rates?
# 4) What are important factors in determining a high freedom country?
#  > linear regression model

# Hypotheses: --------------------------------------------------------------------------------------
# 1) Female suicide rates should decline with increasing women's freedom in a country
#   H0: Female suicide rates will have no/positive relationship with women's freedom??

# 2) Countries with smaller populations tend to have more freedom
#   Ho: mean freedom for countries with small population <= those with large populations
#   Ha: mean freedom for countries with small population >  those with large populations


library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)


hfi_fn <- "../data/hfi_cc_2018.csv"
suicides_fn <- "../data/suicide_rates.csv"

hfi <- read_csv(hfi_fn)
suicides <- read_csv(suicides_fn)


# Explore suicides dataset -------------------------------------------------------------------------
print(str(suicides))
print(summary(suicides))
# By default R reads variables as either numeric or character, but some variables
# like country, year, sex are actually categorical not characters.  We need to update them
# to a factor data type.

suic_fmt <- suicides %>%
    mutate(country = factor(country),
           year = factor(year),
           sex = factor(sex),
           age = factor(age),
           suicides_p100k = `suicides/100k pop`,
           gdp_per_capita = `gdp_per_capita ($)`) %>%
    select(country, year, sex, age, suicides_no, population, suicides_p100k, gdp_per_capita)

print(summary(suic_fmt))
# Now every variable has either a 6 num summary or category breakdown - 4 categorical, 4 numeric
# Initially, just from this we can see all 4 numeric variables have a right skew - their mean is
# larger than their median. Also, there are no missing values within this subset (HDI had some but
# was removed)

print(head(suic_fmt))
print(tail(suic_fmt))
# Nothing unusual with top or bottom, data looks good

## Distribution of variables high-level

# work on moving to Rmd markdown file to show output/plots as we go along.


# Using get() to pass strings as column names:
# var1 = "wt"
# var2 = "mpg"
# p <- ggplot(data=mtcars, aes(get(var1), get(var2)))
# p + geom_point()


print(str(hfi))
print(summary(hfi))
