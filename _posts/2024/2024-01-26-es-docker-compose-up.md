---
layout: post
title: 'Simple dev setup for elasticsearch and kibana'
tags: [elasticsearch, elasticsearch8, kibana, docker, docker-compose]
description: 'Simple dev setup for elasticsearch and kibana'
category: Search
---

This is a mini script that contains all the needed config params. 
It's a stripped down, no security, dev variant of the docker compose script provided by elastic (see link below) to run one ES node and Kibana on your machine.

```shell
#!/bin/bash

# Set environment variables for Docker Compose
export STACK_VERSION="8.12.0"            # Example version for both ES and Kibana
export ES_PORT="9200"                   
export KIBANA_PORT="5601"                
export CLUSTER_NAME="dev-cluster"        
export ES_MEM_LIMIT="8g"                 # Elasticsearch memory limit
export KB_MEM_LIMIT="4g"                 # Kibana memory limit

if [[ "$1" == "down" ]]; then
  docker-compose down
else
  docker-compose up --remove-orphans
fi
```

Docker compose

```yml
version: "3.8"

services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    labels:
      co.elastic.logs/module: elasticsearch
    volumes:
      - esdata01:/usr/share/elasticsearch/data
    ports:
      - ${ES_PORT}:9200
    environment:
      - node.name=es01
      - cluster.name=${CLUSTER_NAME}
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "xpack.security.enabled=false"
    mem_limit: ${ES_MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        - "CMD-SHELL"
        - "curl http://localhost:9200 | grep 'cluster_name'"
      interval: 10s
      timeout: 10s
      retries: 120

  kibana:
    depends_on:
      es01:
        condition: service_healthy
    image: docker.elastic.co/kibana/kibana:${STACK_VERSION}
    labels:
      co.elastic.logs/module: kibana
    volumes:
      - kibanadata:/usr/share/kibana/data
    ports:
      - ${KIBANA_PORT}:5601
    environment:
      - SERVERNAME=kibana
      - ELASTICSEARCH_HOSTS=http://es01:9200
    mem_limit: ${KB_MEM_LIMIT}
    healthcheck:
      test:
        - "CMD-SHELL"
        - "curl -s -I http://localhost:5601 | grep -q 'HTTP/1.1 302 Found'"
      interval: 10s
      timeout: 10s
      retries: 120

volumes:
  esdata01:
    driver: local
  kibanadata:
    driver: local

```

Related articles:

Original source: [Elastic](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose).
Another stripped down version: [Devgenius](https://blog.devgenius.io/elasticsearch-and-kibana-installation-using-docker-compose-886c4823495e)