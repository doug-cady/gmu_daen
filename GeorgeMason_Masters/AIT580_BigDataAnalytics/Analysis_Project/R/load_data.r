# AIT580 Project Spring 2021
# Load data from JSON file
#

library(readr)
library(httr)
library(foreach)
library(rjson)

data.fn <- '../input/dota2_2020-06-02_2020-07-05.csv'

data <- read_csv(data.fn)

# print(head(data))

# num.matches <- rapply(data$match_id, function(x) length(unique(x)))
# print(num.matches)


match.ids <- unique(data$match_id)

# print(length(match.ids))
# print(match.ids)
dota2api.url <- 'https://api.opendota.com/api/matches/'

get.match.data <- function(ids) {
    match.data <- foreach(i = 1:length(ids), .combine = "rbind") %do%
        content(GET(url = paste0(dota2api.url, ids[[i]])))
        # paste0(dota2api.url, ids[[i]])
        # ids[[i]]

    # for(m.id in ids) {
    #     # print(m.id)
    #     m.api.url <- paste0(dota2api.url, m.id)
    #     m.id.data <- GET(url = m.api.url)
    # }
    # print(m.data)
}

all.match.data <- get.match.data(match.ids[1])
# print(all.match.data)

length(all.match.data)
all.match.data$start_time
all.match.data$duration
all.match.data$first_blood_time

# json.data <- fromJSON(file = data.fn)

# print(head(json.data))


schema.url <- 'https://api.opendota.com/api/schema'

# schema <- GET(url = schema.url)

# print(schema)

# names(schema)

# status_code(schema)

# schema.content <- content(schema)

# length(schema.content)

# schema.content[1:5]


match.url <- 'https://api.opendota.com/api/matches/5849989006'
# match <- GET(url = match.url)

# print(status_code(match))

# match.data <- content(match)

# match.data$duration

# length(match.data$players)
