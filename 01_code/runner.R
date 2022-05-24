library(sf)
library(dplyr)


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

