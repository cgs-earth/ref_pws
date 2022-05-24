library(sf)
library(dplyr)

d <- list.files(path = "contribution",
                pattern = ".geojson",
                recursive = TRUE,
                full.names = TRUE)