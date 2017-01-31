FROM python:latest
MAINTAINER Stale Pettersen
RUN pip install 'mongo-connector[elastic2]'
COPY scripts /data
WORKDIR /data
CMD bash /data/run.sh
