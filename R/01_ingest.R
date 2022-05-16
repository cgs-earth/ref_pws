
# list all contributions
l <- list.files("contributions",recursive=TRUE, pattern='*.geojson')

# read them all
d <- lapply(l, sf::st_read)

# combine them all
d <- do.call(rbind,d)
