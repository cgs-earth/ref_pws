# National CWS Boundary Update
A repository to manage the updating of the EPIC/SimpleLab water service boundaries layer with moderated community contributions.

## How it works

This repository includes state-based `contribution/{state-code}` directories where community members may submit `.geojson` files associated with each individual contributed boundary. To create a reproducible workflow, the `runner.R` Rscript will 

1. [x] import the first-cut SimpleLab/EPIC boundary layer [published on Hydroshare](http://www.hydroshare.org/resource/6f3386bb4bc945028391cfabf1ea252e)
2. [x] iterate through the `contribution` folders and `.geojson` files, reading and combining the contributions
3. [x] export the layer to a GeoPackage named `cws.gpkg` and update the corresponding file on Hydroshare


This workflow will be packaged into a Dockerfile that builds a Docker image based on this repository, and exports a finalized `cws.gpkg` to the Hydroshare resource [here](https://www.hydroshare.org/resource/c9d8a6a6d87d4a39a4f05af8ef7675ad/)

To run the workflow:

```
git clone https://github.com/cgs-earth/national-cws-boundary-update
cd national-cws-boundary-update
docker build . -t example/example
docker run example/example
```


## How to contribute

This is a moderated repository. Any user may open a pull request from a fork, submitting a `.geojson` file named `{pwsid}.geojson` to the appropriate state `contribution/{state-code}` directory. The file should be formatted as in this [example](https://github.com/cgs-earth/national-cws-boundary-update/blob/main/contribution/MA/MA3035000.geojson), with 6 fields: 

* `pwsid` as {2-letter-state-code}{pwsid number} e.g. `MA3035000`
* `name`, the name of the water system e.g. `Boston Water and Sewer Service Commission`
* `source_url`, a URL detailing the dataset or organization where the information came from, if available
* `contact_email`, the email address for the person providing the file
* `source_date`, the date that the contributed data was last updated
* `contribution_date`, the date that the data was contributed


