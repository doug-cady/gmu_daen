# -----------------------------------------------------------------------------
# STAT 515 Final Project
# Doug Cady
# Apr 2021

# Nashville, TN police stops dataset

# Stanford open policing project: https://openpolicing.stanford.edu/data/
# US census bureau data: https://www.census.gov/quickfacts/fact/table/nashvilledavidsonbalancetennessee,davidsoncountytennessee/PST045219
# Median income data from: http://www.justicemap.org/include_map.php

# Part 4: Get Income Data from API
# -----------------------------------------------------------------------------


library(httr)
library(jsonlite)
library(dplyr)


base_api_url <- "http://www.spatialjusticetest.org/api.php"


get_lat_lng <- function(df) {
    nrows <- nrow(df)
    final_lat_lng <- tibble(matrix(ncol = 2, nrow = 0))
    colnames(final_lat_lng) <- c("lng", "lat")

    for (i in 1:nrows) {
        cur_mat <- round(df[i, "geometry"][[1]][[1]][[1]], 2)

        colnames(cur_mat) <- c("lng", "lat")

        tmp_lat_lng <- distinct(as_tibble(cur_mat))
        tmp_lat_lng <- cbind(id = i, tmp_lat_lng)

        final_lat_lng <- rbind(final_lat_lng, tmp_lat_lng)
    }

    return (distinct(final_lat_lng))
}


get_med_inc <- function(df) {
    df_w_idx <- cbind(id = 1:nrow(df), df)

    all_lat_lng <- get_lat_lng(df = df_w_idx)

    final_df <- tibble(matrix(ncol = 3, nrow = 0))
    colnames(final_df) <- c("id", "lng", "lat")

    nrows <- nrow(all_lat_lng)

    for (i in 1:nrows) {
        if (i %% 50 == 0) {
            print(i)
        }

        lat <- all_lat_lng[i, "lat"][[1]]
        lng <- all_lat_lng[i, "lng"][[1]]

        api_res <- GET(base_api_url,
                       query = list(fLat = lat, fLon = lng, sGeo = "tract"))

        content <- fromJSON(rawToChar(api_res$content))

        if (content$income != "") {

            res_data <- as_tibble(content)

            res_data <- cbind(id = all_lat_lng[i, "id"][[1]],
                              lng = lng, lat = lat, res_data)

            final_df <- rbind(final_df, res_data)
        } else {print(content$income)}
    }

    merged_dfs <- left_join(df_w_idx, final_df, by = c("id"))

    return (merged_dfs)
}
