download.file("https://www.hydroshare.org/resource/6f3386bb4bc945028391cfabf1ea252e/data/contents/temm_layer_v1.0.0/temm.geojson", destfile="data.geojson")

data <- sf::read_sf("data.geojson")
