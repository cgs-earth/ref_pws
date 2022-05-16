FROM rocker/geospatial:4.2

RUN mkdir -p /00_data
RUN mkdir -p /01_code
RUN mkdir -p /02_output

COPY /R/00_import.R /01_code/00_import.R
COPY /R/01_ingest.R /01_code/01_ingest.R
COPY /R/02_format.R /01_code/02_format.R
COPY /R/03_export.R /01_code/03_export.R
COPY /runner.R /01_code/runner.R

CMD Rscript /01_code/runner.R
