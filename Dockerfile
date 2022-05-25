FROM rocker/geospatial:4.2

RUN mkdir -p /00_data
RUN mkdir -p /01_code
RUN mkdir -p /02_output

#ADD https://www.hydroshare.org/resource/6f3386bb4bc945028391cfabf1ea252e/data/contents/temm_layer_v1.0.0/temm.geojson /00_data/

COPY /00_data/contribution /00_data/contribution

COPY /01_code/runner.R /01_code/runner.R

CMD Rscript /01_code/runner.R
