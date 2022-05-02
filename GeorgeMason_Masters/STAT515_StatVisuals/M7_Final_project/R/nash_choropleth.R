# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219

# Part 3: Shiny choropleth maps for police stops and median income
# -----------------------------------------------------------------------------

# install.packages(c("rgdal", "leaflet"))

# library(rgdal)
# library(leaflet)
library(dplyr)
library(tidyr)
library(magrittr)
library(readr)
library(stringr)
library(ggplot2)
library(sf)  # spatial data objects
library(lubridate) # dates/times

library(RColorBrewer)  # color palettes
library(tmap) # choropleth interactive maps


# Load rds data file ----------------------------------------------------------
stops_fn <- "../input/yg821jf8611_tn_nashville_2020_04_01.rds"

stops <- as_tibble(readRDS(stops_fn))


# Data preparation ------------------------------------------------------------
# 2019 only has a few months of stops, so we remove it to focus on full years
# of data from 2010 to 2018

features <- c(
    "year",
    "month",
    "time",
    "lat",
    "lng",
    "precinct",
    "reporting_area",
    "zone",
    "outcome"
)

stops_10_18 <- stops %>%
    mutate(year = year(date),
           month = month(date)) %>%
    filter(year < 2019,
           outcome != 'summons',
           !subject_race %in% c('unknown', 'other'))

stops_10_18 <- na.omit(stops_10_18) %>%
    mutate(hour = hour(time),
           precinct = factor(precinct),
           reporting_area = factor(reporting_area),
           zone = factor(zone),
           subject_race = factor(subject_race),
           subject_sex = factor(subject_sex),
           outcome = factor(outcome)) %>%
    # Narrow feature set a bit removing raw columns
    dplyr::select(all_of(features))
    # group_by(year, month, time, lat, lng, precinct,
    #          reporting_area, zone, outcome) %>%
    # summarize(outcome_ct = n())

# summary(stops_10_18)
# glimpse(stops_10_18)
# stops_10_18[stops_10_18$lat == tn_shape@data$lat,]





## SF file
# tn_sf <- st_read("../input/tl_2016_47_cousub/")
# str(tn_sf)

# points <- stops_10_18 %>%
#     st_as_sf(coords = c("lng", "lat"), crs = 4269)

# shape_stops <- tn_sf %>%
#     mutate(pol_stops = lengths(st_contains(tn_sf, points))) %>%
#     select(pol_stops)

# summary(shape_stops)

## Ggplot to plotly interactive plot
# ggplot(tn_sf)
# points <- ggmap::fortify(tn_shape, )
# gg_tn_stops <- tn_shape %>%
#     ggplot() +
#     geom_sf()

# gg_tn_stops


## Leaflet plot
# tn_leaf <- st_transform(shape_stops, crs = 4269)

# range(st_coordinates(tn_leaf))

# breaks_qt <- classInt::classIntervals(c(min(tn_leaf$pol_stops) - .00001,
#                                         tn_leaf$pol_stops), n = 7, style = "quantile")

# tn_leaf_brks <- tn_leaf %>%
#     mutate(pol_stops_cat = cut(pol_stops, breaks_qt$brks))

# palette <- colorQuantile("YlOrRd", NULL, n = 5)

# p_popup <- paste0("<strong>Police Stops: </strong>", shape_stops$pol_stops)

# leaflet(tn_leaf_brks) %>%
#     addPolygons(
#         stroke = FALSE,
#         fillColor = ~palette(pol_stops_cat),
#         fillOpacity = 0.8, smoothFactor = 0.5,
#         popup = p_popup
#     )


# 819929.51334682 -107329.42500306


## Nashville zipcodes shapefile -----------------------------------------------
nash_sf <- st_read("../input/Nashville_Zip_Codes/")
str(nash_sf)

plot(nash_sf)

st_crs(nash_sf) <- 4326

points_nash <- stops_10_18 %>%
    st_as_sf(coords = c("lng", "lat"), crs = 4326)

nash_shape_stops <- nash_sf %>%
    mutate(pol_stops = lengths(st_contains(nash_sf, points_nash))) %>%
    select(pol_stops, zip, po_name) %>%
    filter(pol_stops > 0)


## Add in median income info --------------------------------------------------
source("get_med_income_api.R")
med_inc <- get_med_inc(df = nash_shape_stops)
# head(med_inc)

st_write(med_inc,
         dsn = "../output/nash_stops_incomes_geo3.gpkg",
         delete_dsn = F)

# summary(med_inc)
# head(med_inc)




## tmap plot ------------------------------------------------------------------

col_palette <- rev(brewer.pal(7, "YlGnBu"))
# col_palette <- rev(brewer.pal(7, "GnBu"))
# col_palette <- rev(brewer.pal(7, "PuBu"))
# col_palette <- rev(brewer.pal(7, "YlOrRd"))

med_inc_pop <- med_inc %>%
    mutate(income_num = as.numeric(income),
           income_popup = if_else(
                nchar(income) == 5,
                paste0("$", str_sub(income, 1, 2), ",", str_sub(income, 3, 5)),
                paste0("$", str_sub(income, 1, 3), ",", str_sub(income, 4, 6))))


# med_inc$income_num <- as.numeric(med_inc$income)

# make_list_text_sep <- function(data, col, dig) {
#     brk1 <- paste(round(data$col, dig), "to")
#     print(brk1)
#     # brk2 <- round(data[2:length(data$col), data$col], dig)

#     # concat_brks <- paste(brk1, brk2)
#     # return (concat_brks[1:7])
# }

breaks_qt <- classInt::classIntervals(c(min(med_inc_pop$pol_stops) - .00001,
                                        med_inc_pop$pol_stops),
                                      n = 7, style = "quantile", digits = 4)

breaks_qt_inc <- classInt::classIntervals(c(min(med_inc_pop$income_num) - .00001,
                                           med_inc_pop$income_num),
                                          n = 7, style = "quantile", digits = 4)

# glimpse(med_inc)
# breaks_qt_inc$brks
# breaks_qt_inc[, "brks"]
# brk1 <- paste(round(breaks_qt_inc$brks, 0), "to")
# brk1 <- paste(round(breaks_qt_inc[, "brks"], 0), "to")
# brk2 <- round(breaks_qt_inc$brks[2:length(breaks_qt_inc$brks)], 0)
# brk1
# brk2
# paste(brk1, brk2)

# stop_cat_labels <- make_list_text_sep(breaks_qt, "brks", 0)

stop_cat_labels <- c(
    "1 to 33",
    "33 to 67",
    "67 to 157",
    "157 to 552",
    "552 to 999",
    "999 to 1,520",
    "1,520 to 2,861")

income_cat_labels <- c(
    "$12,128 to $43,429",
    "$43,429 to $57,775",
    "$57,775 to $62,750",
    "$62,750 to $66,598",
    "$66,598 to $71,593",
    "$71,593 to $89,473",
    "$89,473 to $181,250")

stops_med_inc <- med_inc_pop %>%
    mutate(pol_stops_cat = cut(pol_stops, breaks_qt$brks,
                               labels = stop_cat_labels),
           income_cat = cut(income_num, breaks_qt_inc$brks,
                               labels = income_cat_labels)
    )

# stops_med_inc$income_cat <- forcats::fct_rev(stops_med_inc$income_cat)
stops_med_inc$pol_stops_cat <- forcats::fct_rev(stops_med_inc$pol_stops_cat)

stops_med_inc <- stops_med_inc %>%
    mutate(po_name_zip = paste0(po_name, " - ", zip)) %>%
    # po_name_zip to first column
    select(po_name_zip, id:income_cat)

st_write(stops_med_inc,
         dsn = "../output/nash_stops_incomes_geo4.gpkg",
         delete_dsn = T)

# glimpse(stops_med_inc)
# levels(stops_med_inc$pol_stops_cat)
# levels(stops_med_inc$income_cat)
# stops_med_inc[stops_med_inc$zip == 37217, ]

## Make tmap plot (faceted)
(edi_nash_tmap <-
    # tm_basemap("OpenStreetMap.Mapnik") +
    # tm_basemap(leaflet::providers$Stamen.Watercolor) +
    tm_shape(stops_med_inc) +
    # tm_shape(stops_med_inc, bbox = bbox_new) +
    tm_sf(col = c("pol_stops_cat", "income_cat"),
          title = c("Police Stops in Davidson County, TN (2010 - 2018)",
                    "2018 Median Income in Davidson County, TN"),
          palette = palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup")) +
    tm_facets(sync = TRUE, nrow = 2)
    # tm_facets(sync = TRUE, nrow = 2) +
    # tm_layout(panel.show = TRUE)
)

## Arranged grid of 2 plots (not faceted)
edi_nash_tmap_stops <- tm_shape(stops_med_inc) +
    tm_sf(col = "pol_stops_cat",
          title = "Police Stops in Davidson County, TN (2010 - 2018)",
          palette = palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

edi_nash_tmap_inc <- tm_shape(stops_med_inc) +
    tm_sf(col = "income_cat",
          title = "2018 Median Income in Davidson County, TN)",
          palette = palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income_popup"))

# tmap_arrange(edi_nash_tmap_stops, edi_nash_tmap_inc)
tmap_arrange(edi_nash_tmap_stops, edi_nash_tmap_inc, nrow = 2, sync = TRUE, asp = NA)

# tmap_save(edi_nash_tmap, filename = "../graphics/stops_medInc_interactive.html")


# JUNK ------------------------------------------------------------------------


## ggplot plot
# library(plotly)

# tn_leaf <- st_transform(nash_shape_stops, crs = 4326)

# tn_leaf_brks <- tn_leaf %>%
#     mutate(pol_stops_cat = cut(pol_stops, breaks_qt$brks))

    # mutate(pol_stops_cat = factor(cut(pol_stops, breaks_qt$brks),
    #                               levels = breaks_qt$brks))

# gg_nash_stops <- ggplot(tn_leaf_brks) +
#     geom_sf(aes(fill = pol_stops_cat)) +
#     scale_fill_brewer(palette = "OrRd")

# ggplotly(gg_nash_stops)





# Adjust bounding box limits of plot
# xchg <- 0.2
# ychg <- 0.1

# bbox_new <- st_bbox(stops_med_inc)

# bbox_new[1] <- bbox_new[1] + xchg
# bbox_new[2] <- bbox_new[2] - ychg
# bbox_new[3] <- bbox_new[3] - xchg
# bbox_new[4] <- bbox_new[4] + ychg

# bbox_new <- bbox_new %>%
#     st_as_sfc()


## leaflet from tmap
# tmap_leaf <- tmap_leaflet(edi_nash_tmap, mode = "view", show = FALSE) %>%
#     setView(819929, -107329, zoom = 11) %>%
#     fitBounds(xmin, ymin, xmax, ymax) %>%
#     clearBounds()

# pacman::p_load(htmlwidgets)
# tmap_leaf

# tmap_mode("view")
# tmap_last()



# -86°47'6.637", 36°11'13.006" nashville lon, lat


## Leaflet plot
# tn_leaf <- st_transform(nash_shape_stops, crs = 4326)

# # range(st_coordinates(tn_leaf))

# breaks_qt <- classInt::classIntervals(c(min(tn_leaf$pol_stops) - .00001,
#                                         tn_leaf$pol_stops), n = 7, style = "quantile")

# tn_leaf_brks <- tn_leaf %>%
#     mutate(pol_stops_cat = factor(cut(pol_stops, breaks_qt$brks),
#                                   levels = breaks_qt$brks))

# glimpse(tn_leaf_brks)

# palette <- colorQuantile("YlOrRd", NULL, n = 5)

# p_popup <- paste0("<strong>Police Stops: </strong>", nash_shape_stops$pol_stops)

# leaflet(tn_leaf_brks) %>%
#     addPolygons(
#         stroke = FALSE,
#         fillColor = ~palette(pol_stops_cat),
#         fillOpacity = 0.8, smoothFactor = 0.5,
#         popup = p_popup
#     )


## Merging shape and police stops ---------------------------------------------
# state_join <- dplyr::left_join(x = tn_shape@data, y = stops_10_18)
# glimpse(state_join)

# # state_clean <- na.omit(state_join)
# # glimpse(state_clean)

# STATE_SHP <- sp::merge(x = tn_shape, y = state_join)




## Preparing shape file -------------------------------------------------------
# tn_shape <- readOGR(
#     dsn = "../input/tl_2016_47_cousub/",
#     layer = "tl_2016_47_cousub",
#     verbose = FALSE
# )

# class(tn_shape)

# names(tn_shape)

# repl_chars <- function(data, repl_col, old_col) {
#     data[, repl_col] <- as.numeric(gsub('"', "", data[, old_col]))
#     data[, repl_col] <- round(data[, repl_col], 2)
# }

# tn_shape@data$lat <- repl_chars(data = tn_shape@data,
#                                 repl_col = "INTPTLAT_RD",
#                                 old_col = "INTPTLAT")

# tn_shape@data$lng <- repl_chars(data = tn_shape@data,
#                                 repl_col = "INTPTLON_RD",
#                                 old_col = "INTPTLON")

# glimpse(tn_shape)

