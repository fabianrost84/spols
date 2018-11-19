FROM continuumio/miniconda3:latest
MAINTAINER Fabian Rost <fabrost@pks.mpg.de>

WORKDIR /root

COPY environment.yml /root
RUN conda env update

COPY Rpackages.R /root
RUN Rscript Rpackages.R
