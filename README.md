# docker-filebeat

Containerized, multiarch version of filebeat

## How to Build

Build using `buildx` for multiarchitecture image and manifest support

Setup buildx

```bash
docker buildx create --name multiarchbuilder
docker buildx use multiarchbuilder
docker buildx inspect --bootstrap
[+] Building 0.0s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                 5.7s 
 => => pulling image moby/buildkit:buildx-stable-1                                                                                              4.6s 
 => => creating container buildx_buildkit_multiarchbuilder0                                                                                     1.1s 
Name:   multiarchbuilder
Driver: docker-container

Nodes:
Name:      multiarchbuilder0
Endpoint:  npipe:////./pipe/docker_engine
Status:    running
Platforms: linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

Build

```bash
docker buildx build --platform linux/arm -t jmb12686/filebeat:latest --push .
```

## How to Run

Run on a single Docker engine node:

```bash
sudo docker run -it  \
  --name=filebeat   --user=root \
  --volume="PATH_TO_CONFIG/filebeat.yml:/usr/share/filebeat/filebeat.yml" \
  --volume="/var/lib/docker/containers:/var/lib/docker/containers:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  -e ELASTICSEARCH_HOST=elasticsearch-url \
  -e KIBANA_HOST=kibana-url
  jmb12686/filebeat \
  --strict.perms=false
```

Run with with Compose on Docker Swarm:

```yml
version: "3.7"
services:
  filebeat:
    image: jmb12686/filebeat
    hostname: "{{.Node.Hostname}}-filebeat"
    user: root
    networks:
      - elk
    configs:
      - source: filebeat_config
        target: /usr/share/filebeat/filebeat.yml
    volumes:
      - filebeat:/usr/share/filebeat/data
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/containers/:/var/lib/docker/containers/:ro
      - /var/log/:/var/log/:ro
    environment:
      - ELASTICSEARCH_HOST:elasticsearch
      - KIBANA_HOST:kibana
    command: ["--strict.perms=false"]
    deploy:
      mode: global
configs:
  filebeat_config:
    name: filebeat_config-${CONFIG_VERSION:-0}
    file: ./filebeat/config/filebeat.yml
networks:
  elk:
    driver: overlay
volumes:
  filebeat: {}
```
