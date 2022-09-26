library(sf)
library(dplyr)
library(purrr)
library(httr)
library(readr)

sf::sf_use_s2(FALSE)
## Read, clean, and combine the contributed data
d <- list.files(
  path = "00_data/contribution",
  pattern = ".geojson",
  recursive = TRUE,
  full.names = TRUE
) %>%
  lapply(st_read) %>%
  map_dfr(~mutate(., across(-geometry, as.character))) %>%
  st_zm() %>%
  bind_rows() %>%
  group_by(pwsid) %>%
  summarize(
    name = first(name),
    source_url = first(source_url),
    data_source = first(data_source),
    contact_email = first(contact_email),
    source_date = first(source_date),
    contribution_date = first(contribution_date),
    service_area_type = first(service_area_type),
    tier = "Tier 1"
  ) %>%
  rename(pws_name = name)


existing <- sf::read_sf("00_data/temm.geojson/temm.geojson")
existing$source_url <- "https://www.hydroshare.org/resource/b11b8982eebd4843833932f085f71d92/data/contents/temm.geojson"
existing$data_source = "SimpleLab"
existing$contact_email = "jess@gosimplelab.com"
existing$source_date = "2022-07-05"
existing$contribution_date = "2022-07-05"

x <- existing
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

x$service_area_type_code <- NULL

x <- x %>% mutate(primary_water_source = case_when(
  primary_source_code == "SWP" ~ "Purchased Surface Water",
  primary_source_code == "GWP" ~ "Purchased Groundwater",
  primary_source_code == "GW" ~ "Groundwater",
  primary_source_code == "SW" ~ "Surface Water",
  primary_source_code == "GU" ~ "Groundwater under influence of surface water",
  primary_source_code == "GUP" ~ "Purchased groundwater under influence of surface water")
)

x$sdwis_link <- paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",x$pwsid,"&state=",x$state_code,"&source=0&population=0")
x$place_uri <- paste0("https://geoconnex.us/ref/places/",x$matched_bound_geoid)
x <- x %>% mutate(wholesaler=case_when(
  is_wholesaler_ind == 1 ~ "Is a wholesaler",
  is_wholesaler_ind == 0 ~ "Is not a wholesaler"
))

x$uri <- paste0("https://geoconnex.us/ref/pws/",x$pwsid)

states <- sf::read_sf("https://reference.geoconnex.us/collections/states/items?skipGeometry=true") %>% 
  select(uri,STUSPS) %>% 
  st_drop_geometry() %>% 
  rename(state_uri = uri)

x <- left_join(x,states,by=c("state_code" = "STUSPS"))

for(i in d$pwsid){
  x$geometry[which(x$pwsid==i)] <- d$geometry[which(d$pwsid==i)]
  print(paste0(i, "geo done"))
  x$name[which(x$pwsid==i)] <- d$name[which(d$pwsid==i)]
  print(paste0(i, "ma,e done"))
  x$source_url[which(x$pwsid==i)] <- d$source_url[which(d$pwsid==i)]
  print(paste0(i, "soruce done"))
  x$data_source[which(x$pwsid==i)] <- d$data_source[which(d$pwsid==i)]
  print(paste0(i, "data done"))
  x$contact_email[which(x$pwsid==i)] <- d$contact_email[which(d$pwsid==i)]
  print(paste0(i, "email done"))
  x$source_date[which(x$pwsid==i)] <- d$source_date[which(d$pwsid==i)]
  print(paste0(i, "date done"))
  x$contribution_date[which(x$pwsid==i)] <- d$contribution_date[which(d$pwsid==i)]
  print(paste0(i, "contr done"))
  x$service_area_type[which(x$pwsid==i)] <- d$service_area_type[which(d$pwsid==i)]
  print(paste0(i, "tier done"))
  x$tier[which(x$pwsid==i)] <- d$tier[which(d$pwsid==i)]
  print(paste0(i, "tier done"))
}

x <- x %>% mutate(BOUNDARY_TYPE = case_when(
  tier == "none" ~ "no boundary",
  tier == "Tier 1" ~ "Water Service Area - as specified in source_url",
  tier == "Tier 2a" ~ "Unknown Service Area - Using relevant U.S. Census Places Catographic Boundary Polygon to represent PWS",
  tier == "Tier 3" ~ "Unknown Service Area - Using EPA ECHO facility location with buffered radius to represent PWS")
)

hs_user <- "changme"
hs_pw <- "changeme"


## Write out the data
file <- "ref_pws.gpkg"
path <- paste0("02_output/",file)
write_sf(x,path)

pids <- x %>% 
  filter(BOUNDARY_TYPE!="no boundary") %>%
  select(pwsid) %>%
  mutate(id = paste0("https://geoconnex.us/ref/pws/",pwsid),
         target=paste0("https://reference.geoconnex.us/collections/pws/items/",pwsid),
         creator="konda@lincolninst.edu",
         description="pids for community water system boundaries") %>%
  st_drop_geometry() %>%
  select(-pwsid)

write_csv(pids,file="02_output/pws.csv", append=FALSE)

#Write out just the new data
contributed_file <- "contributed_pws.gpkg"
contributed_path <- paste0("02_output/",contributed_file)
write_sf(d,contributed_path)

## Post the data to hydroshare (DELETES if already exists)

api <- "https://www.hydroshare.org/hsapi/resource/"
id <- "c9d8a6a6d87d4a39a4f05af8ef7675ad"
post_url <- paste0(api,id,"/files/./")
post_ref_url <- "https://www.hydroshare.org/hsapi/resource/3295a17b4cc24d34bd6a5c5aaf753c50/files/./"
delete_url <- paste0(api,id,"/files/./",file)
delete_ref_url <- "https://www.hydroshare.org/hsapi/resource/3295a17b4cc24d34bd6a5c5aaf753c50/files/./ref_pws.gpkg"
contributed_delete_url <- paste0(api,id,"/files/./",contributed_file)

try(DELETE(delete_url, 
     authenticate(hs_user, hs_pw), timeout(300)))

try(DELETE("https://www.hydroshare.org/hsapi/resource/3295a17b4cc24d34bd6a5c5aaf753c50/files/./pws.csv",
           authenticate(hs_user,hs_pw), timeout(300)))

try(DELETE(contributed_delete_url, 
           authenticate(hs_user, hs_pw), timeout(300)))

try(DELETE(delete_ref_url, 
           authenticate(hs_user, hs_pw), timeout(300)))


POST(post_ref_url, 
     body = list(file=upload_file(path)), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw),
     timeout(300))

POST(post_url, 
     body = list(file=upload_file(path)), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw),
     timeout(300))

POST(post_url, 
     body = list(file=upload_file(contributed_path)), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw), timeout(300))

POST(post_ref_url, 
     body = list(file=upload_file("02_output/pws.csv")), 
     encode = "multipart", 
     authenticate(hs_user, hs_pw), timeout(300))


unlink(path)
unlink(contributed_path)
