# National CWS Boundary Update
A repository to manage the updating of the EPIC/SimpleLab water service boundaries layer with moderated community contributions.

## How it works

This repository includes state-based `contribution/{state-code}` directories where community members may submit `.geojson` files associated with each individual contributed boundary. To create a reproducible workflow a docker image includes `runner.R` that

1. [x] iterates through the `contribution` folders and `.geojson` files, reading and combining the contributions
2. [x] exports the layer to a GeoPackage named `cws.gpkg` and updates the corresponding file on a dedicated [Hydroshare resource](https://www.hydroshare.org/resource/c9d8a6a6d87d4a39a4f05af8ef7675ad/)


## How to contribute

This is a moderated repository. Any user may open a pull request from a fork, submitting a `.geojson` file named `{pwsid}.geojson` to the appropriate state `contribution/{state-code}` directory. The file should be formatted as in this [example](https://github.com/cgs-earth/national-cws-boundary-update/blob/main/00_data/contribution/MA/MA3035000.geojson), with 7 fields: 

* `pwsid` as {2-letter-state-code}{pwsid number} e.g. `MA3035000`
* `name`, the name of the water system e.g. `Boston Water and Sewer Service Commission`
* `data_source`, the type of data that the boundary was generated from, which can be one of:
   * Census Place
   * Image from Utility
   * Description from Utility
   * Water Lines
   * Layer from Utility
   * County boundary with other systems removed
* `source_url`, a URL detailing the dataset or organization where the information came from, if available
* `contact_email`, the email address for the person providing the file
* `source_date`, the date that the contributed data was last updated
* `contribution_date`, the date that the data was contributed


