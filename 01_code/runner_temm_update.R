library(sf)
library(dplyr)
library(httr)


## Read the newest temm data
url <- "https://www.hydroshare.org/django_irods/rest_download/zips/2022-07-11/29c110cfe9154fdd9bf79ce2fb499c05/20b908d73a784fc1a097a3b3f2b58bfb/data/contents/temm.geojson.zip"
download.file(url, destfile = "00_data/temm_v2.geojson.zip")
unzip("00_data/temm_v2.geojson.zip", exdir="00_data")

temm <- sf::read_sf("00_Data/temm.geojson/temm.geojson")

## Recode service area types
x <- temm
x$service_area_type <- x$service_area_type_code


index <- c("DC",
           "DI",
           "HA",
           "HM",
           "HR",
           "IA",
           "IC",
           "IN","MF","MH","MP","MU","OA","ON","OR","OT","PA","RA","RE","RS","SC","SI","SK","SR","SS","SU","WB","WH")
values <-c("Daycare Center","Dispenser","Homeowners Association","Hotel/Motel","Highway Rest Area","Industrial/Agricultural","Interstate Carrier",
           "Institution","Medical Facility","Mobile Home Park","Mobile Home Park - Principal Residence","Municipality",
           "Other Area","Other Non-transient Area","Other Residential","Other Transient Area","Recreation Area","Residential Area","Retail Employees",
           "Restaurant","School","Sanitary Improvement District","Summer Camp","Secondary Residences","Service Station","Subdivision","Water Bottler","Wholesaler of Water")


for (i in 1:length(index)) {
  
  x$service_area_type <- gsub(index[i],values[i], x$service_area_type)
  
}

x <- x %>% mutate(primary_water_source = case_when(
  primary_source_code == "SWP" ~ "Purchased Surface Water",
  primary_source_code == "GWP" ~ "Purchased Groundwater",
  primary_source_code == "GW" ~ "Groundwater",
  primary_source_code == "SW" ~ "Surface Water",
  primary_source_code == "GU" ~ "Groundwater under influence of surface water",
  primary_source_code == "GUP" ~ "Purchased groundwater under influence of surface water")
)

x$sdwis_link <- paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",x$pwsid,"&state=",x$state_code,"&source=0&population=0")
x$place_link <- paste0("https://data.census.gov/cedsci/profile?g=1600000US",x$matched_bound_geoid)
x <- x %>% mutate(wholesaler=case_when(
  is_wholesaler_ind == 1 ~ "Is a wholesaler",
  is_wholesaler_ind == 0 ~ "Is not a wholesaler"
))

## Write out the data
file.gpkg <- "cws.gpkg"
file.shp <- "cws.shp"
x2 <- x %>% sf::abbreviate_shapefile_names(x)
path.shp <- paste0("02_output/",file.shp)
path.gpkg <- paste0("02_output/",file.gpkg)
sf::write_sf(x,"cws.gdb")
sf::write_sf(x,path.gpkg)

## Post the data to hydroshare (DELETES if already exists)

api <- "https://www.hydroshare.org/hsapi/resource/"
id <- "c9d8a6a6d87d4a39a4f05af8ef7675ad"
post_url <- paste0(api,id,"/files/./")
delete_url <- paste0(api,id,"/files/./",file.gpkg)


hs_user <- "cgsiow"
hs_pw <- "IoWAdmin!"

try(DELETE(delete_url, 
     authenticate(hs_user, hs_pw)))

POST(post_url, 
     body = list(file=upload_file(path.gpkg)), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw))

#unlink("cws.gpkg")

