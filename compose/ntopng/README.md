# Sample ntopng Docker Compose Configuration

This folder contains a sample `compose.yml` Docker Compose configuration file used to run 
ntopng and ClickHouse for [historic flows](https://www.ntop.org/guides/ntopng/clickhouse.html) 
as 2 Docker containers. Container images from [Dockerhub](https://hub.docker.com/u/ntop) are used.

Run the containers:

```
sudo docker-compose up -d
```

Stop the containers:

```
sudo docker-compose down
```
