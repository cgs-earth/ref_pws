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

hs_user <- "HYDROSHARE_we"
hs_pw <- "HYDROSHARE_PW"


## Write out the data
file <- "cws.gpkg"
path <- paste0("02_output/",file)
write_sf(d,path)

## Post the data to hydroshare (DELETES if already exists)

api <- "https://www.hydroshare.org/hsapi/resource/"
id <- "c9d8a6a6d87d4a39a4f05af8ef7675ad"
post_url <- paste0(api,id,"/files/./")
delete_url <- paste0(api,id,"/files/./",file)

try(DELETE(delete_url, 
     authenticate(hs_user, hs_pw)))

POST(post_url, 
     body = list(file=upload_file(path)), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw))

unlink("cws.gpkg")

