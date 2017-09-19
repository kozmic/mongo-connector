This fork adds the configuration option `WAIT_FOR_PRIMARY`, legal values are `enabled` and `disabled`. Enabling this will wait for the tcp port to the mongo server to be open before it connects, and will wait for the mongo server to be the primary replication set before starting the mongo-connector.

# mongo-connector
Dockerized Mongo Connector that uses volumes, a config file, and latest document manager for Elasticsearch 2.x. Automated build at dockerhub https://hub.docker.com/r/kozmico/mongo-connector

Tested with Mongo 2.4.x and Elasticsearch 2.3.

Installs:
* Latest Python (currentl 3.6.0)
* Latest mongo-connector (currently 2.5.0)
* Latest elastic2-doc-manager\[eleastic2\] (currently 0.3.0)

Mounts `scripts` into `/data` and then start the mongo-connector at boot with `bash /data/run.sh`.
`run.sh` expects the environment variable `CONFIG_PATH` to point to a `mongo-connector.conf` which contains configuration options like addresses to your Mongo and ES servers.
By default `CONFIG_PATH` points to `/data/config/config.json`.

Example `docker-compose.yml`:

```
  mongo1:
      image: mongo:2.4
      ports:
        - 27017:27017
        
    elasticsearch1:
      image: elasticsearch:2.3
      ports:
        - 9200:9200

    mongodata:
      image: tianon/true
      volumes:
        - ./local-folder/config:/data/config
        
    mongo-connector1:
      image: kozmico/mongo-connector
      volumes_from:
        - mongodata
      links:
        - mongo1:mongo
        - elasticsearch1:elasticsearch
      environment:
        - CONFIG_PATH=/data/config/mongo-connector.conf
	- WAIT_FOR_PRIMARY=enabled
      depends_on:
        - mongo1
        - elasticsearch1
```
