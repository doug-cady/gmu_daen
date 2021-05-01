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
library(magrittr)
library(readr)
library(ggplot2)
library(sf)
library(lubridate)

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


## Nashville zipcodes shapefile
nash_sf <- st_read("../input/Nashville_Zip_Codes/")
str(nash_sf)

st_crs(nash_sf) <- 4326

points_nash <- stops_10_18 %>%
    st_as_sf(coords = c("lng", "lat"), crs = 4326)

nash_shape_stops <- nash_sf %>%
    mutate(pol_stops = lengths(st_contains(nash_sf, points_nash))) %>%
    select(pol_stops) %>%
    filter(pol_stops > 0)


## Add in median income info
source("get_med_income_api.R")
# med_inc <- get_med_inc(df = nash_shape_stops)
# head(med_inc)

st_write(med_inc,
         dsn = "../output/nash_stops_incomes_geo.gpkg",
         delete_dsn = F)

summary(med_inc)

# nash_stops_medInc <- nash_shape_stops %>%
    # left_join(med_inc, by = c("lng", "lat"))


# med_inc_names <- c("TBLID", "GEOID", "GEONAME", "PROFLN", "ESTIMATE", "MG_ERROR")
# med_inc <- read_csv("../input/GCT1901.csv", col_names = med_inc_names, skip = 2)

# tail(med_inc)

# nash_med_inc <- med_inc %>%
#     filter(str_detect(GEONAME, ""))




## ggplot plot
library(RColorBrewer)
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


## tmap plot
library(tmap)

palette <- rev(brewer.pal(7, "RdYlGn"))


med_inc$income_num <- as.numeric(med_inc$income)

make_list_text_sep <- function(data, col, dig) {
    brk1 <- paste(round(data$col, dig), "to")
    print(brk1)
    # brk2 <- round(data[2:length(data$col), data$col], dig)

    # concat_brks <- paste(brk1, brk2)
    # return (concat_brks[1:7])
}

breaks_qt <- classInt::classIntervals(c(min(med_inc$pol_stops) - .00001,
                                        med_inc$pol_stops),
                                      n = 7, style = "quantile", digits = 4)

breaks_qt_inc <- classInt::classIntervals(c(min(med_inc$income_num) - .00001,
                                           med_inc$income_num),
                                          n = 7, style = "quantile", digits = 4)

glimpse(med_inc)
breaks_qt_inc$brks
breaks_qt_inc[, "brks"]
brk1 <- paste(round(breaks_qt_inc$brks, 0), "to")
brk1 <- paste(round(breaks_qt_inc[, "brks"], 0), "to")
brk2 <- round(breaks_qt_inc$brks[2:length(breaks_qt_inc$brks)], 0)
brk1
brk2
paste(brk1, brk2)

stop_cat_labels <- make_list_text_sep(breaks_qt, "brks", 0)

stop_cat_labels <- c(
    "1 to 33",
    "33 to 67",
    "67 to 157",
    "157 to 552",
    "552 to 999",
    "999 to 1,520",
    "1,520 to 2,861")

income_cat_labels <- c(
    "12128 to 43429",
    "43429 to 57775",
    "57775 to 62750",
    "62750 to 66598",
    "66598 to 71593",
    "71593 to 89473",
    "89473 to 181250")

stops_med_inc <- med_inc %>%
    mutate(pol_stops_cat = cut(pol_stops, breaks_qt$brks,
                               labels = stop_cat_labels),
           income_cat = cut(income_num, breaks_qt_inc$brks,
                               labels = income_cat_labels)
    )

stops_med_inc$income_cat <- forcats::fct_rev(stops_med_inc$income_cat)

(edi_nash_tmap <-
    tm_basemap("OpenStreetMap.Mapnik") +
    # tm_shape(nash_shape_stops) +
    tm_shape(stops_med_inc) +
    # tm_polygons("pol_stops",
    #             style = "quantile",
    #             palette = palette,
    #             title = "Davidson County, TN\nPolice Stops\n2010 - 2018") +
    tm_sf(col = c("pol_stops_cat", "income_cat"),
          title = c("Davidson County, TN Police Stops 2010 - 2018",
                    "Davidson County, TN Median Income 2018"),
          palette = palette,
          style = "quantile",
          popup.vars = c("Police Stops " = "pol_stops",
                         "Median Income " = "income")) +
    tm_facets(sync = TRUE, ncol = 2)
    # tm_layout(legend.format = list(format = "f"))
)

# tm_shape(tn_leaf_brks) +
#     tm_polygons("pol_stops_cat",
#                 style = "quantile",
#                 palette = palette,
#                 title = "Davidson County, TN\nPolice Stops\n2010 - 2018")

tmap_mode("view")
tmap_last()

st_write(stops_med_inc,
         dsn = "../output/nash_stops_incomes_geo2.gpkg",
         delete_dsn = F)

tmap_save(edi_nash_tmap, filename = "../graphics/stops_medInc_interactive.html")

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

