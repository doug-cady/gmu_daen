# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219

# Part 3: tmap choropleth maps for police stops and median income
# -----------------------------------------------------------------------------

library(sf)
library(tmap)
library(dplyr)
library(RColorBrewer)

# Read in gpkg file
gpkg_data <- st_read("../output/nash_stops_incomes_geo4.gpkg")

pol_stops_cat_nchar <- nchar(gpkg_data$pol_stops_cat)

# str(gpkg_data)

# Reorder police stops categories for plot legends and colors
gpkg_fmt <- gpkg_data %>%
    mutate(pol_stops_cat_nchar = nchar(pol_stops_cat),
           pol_stops_cat = factor(pol_stops_cat))

gpkg_fmt$pol_stops_cat <- reorder(gpkg_fmt$pol_stops_cat, -gpkg_fmt$pol_stops_cat_nchar)

col_palette <- rev(brewer.pal(7, "YlGnBu"))

# tmap_mode("plot")
tmap_mode("view")

## Arranged grid of 2 plots (not faceted)
edi_nash_tmap_stops <- tm_shape(gpkg_fmt) +
    tm_sf(col = "pol_stops_cat",
          title = "Police Stops in Davidson County, TN (2010 - 2018)",
          palette = col_palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

edi_nash_tmap_inc <- tm_shape(gpkg_fmt) +
    tm_sf(col = "income_cat",
          title = "2018 Median Income in Davidson County, TN)",
          palette = col_palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

tmap_arrange(edi_nash_tmap_stops, edi_nash_tmap_inc, nrow = 2, sync = TRUE, asp = NA)
