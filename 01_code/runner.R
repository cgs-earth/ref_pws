library(sf)
library(dplyr)
library(httr)


## Read, clean, and combine the contributed data
d <- list.files(
  path = "00_data/contribution",
  pattern = ".geojson",
  recursive = TRUE,
  full.names = TRUE
) %>%
  lapply(st_read) %>%
  st_zm() %>%
  bind_rows() %>%
  group_by(pwsid) %>%
  summarize(
    name = first(name),
    source_url = first(source_url),
    contact_email = first(contact_email),
    source_date = first(source_date),
    contribution_date = first(contribution_date)
  )


## Write out the data
write_sf(d,"02_output/out.gpkg")

## Post the data to hydroshare

url <- "https://www.hydroshare.org/hsapi/resource/4bc8f1ee44644268a7b9edbd58b01047/files/test/"

DELETE(paste0("https://www.hydroshare.org/hsapi/resource/4bc8f1ee44644268a7b9edbd58b01047/files/test/",
              "out.gpkg"), 
     authenticate("user", "pw"))

POST(url, 
     body = list(file=upload_file("02_output/out.gpkg")), 
     encode = "multipart", 
     authenticate("user", "pw"))


