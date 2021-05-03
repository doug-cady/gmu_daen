# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219

# Part 3: Shiny choropleth maps for police stops and median income
# -----------------------------------------------------------------------------

library(sf)
library(tmap)
library(RColorBrewer)

# Read in gpkg file
gpkg_data <- st_read("../output/nash_stops_incomes_geo4.gpkg")

str(gpkg_data)

col_palette <- rev(brewer.pal(7, "YlGnBu"))

tmap_mode("view")

## Arranged grid of 2 plots (not faceted)
edi_nash_tmap_stops <- tm_shape(gpkg_data) +
    tm_sf(col = "pol_stops_cat",
          title = "Police Stops in Davidson County, TN (2010 - 2018)",
          palette = col_palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

edi_nash_tmap_inc <- tm_shape(gpkg_data) +
    tm_sf(col = "income_cat",
          title = "2018 Median Income in Davidson County, TN)",
          palette = col_palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

# tmap_arrange(edi_nash_tmap_stops, edi_nash_tmap_inc)
tmap_arrange(edi_nash_tmap_stops, edi_nash_tmap_inc, nrow = 2, sync = TRUE, asp = NA)
