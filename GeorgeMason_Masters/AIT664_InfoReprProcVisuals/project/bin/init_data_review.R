# Initial data review for AIT 664 data visualization project
# on Human Freedom Index and suicide rates

# Doug Cady
# Oct. 28, 2021

library(readr)


hfi_fn <- "../data/hfi_cc_2018.csv"
suicides_fn <- "../data/suicide_rates.csv"

hfi <- read_csv(hfi_fn)
suicides <- read_csv(suicides_fn)

print(str(suicides))
print(str(hfi))


print(summary(suicides))
print(summary(hfi))
