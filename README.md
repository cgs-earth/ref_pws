# national-cws-boundary-update
A repository to manage the updating of the EPIC/SimpleLab water service boundaries layer with moderated community contributions.

## How it works

This repository includes state-based `contribution/{state-code}` directories where community members may submit `.geojson` files associated with each inividual contributed boundary. To create a reproducible workflow, the following Rscripts will be created:

1. `R/00_initialize.R`  that imports the first-cut SimpleLab/EPIC boundary layer [published on Hydroshare](http://www.hydroshare.org/resource/6f3386bb4bc945028391cfabf1ea252e)
2. `R/01_ingest.R` that iterates through the `contribution` folders and `.geojson` files, replacing the appropritate polygons in initial boundary layer with the contributions
3. `R/02_format.R` that renames variables and adds value-added attributes
4. `R/03_export.R` that exports the layer to a GeoPackage named `cws.gpkg`
5. `runner.R` that runs the above scripts int he correct workflow


This workflow will be packaged into a Dockerfile that builds a Docker image based on this repository, and exports a finalized `cws.gpkg` to the user's mapped Docker volume. 

## How to contribute

This is a moderated repository. Any user may open a pull request, submitting a `.geojson` file named `{pwsid}.geojson` to the appropriate state `contribution/{state-code}` directory. The file should be formatted as in this example:


