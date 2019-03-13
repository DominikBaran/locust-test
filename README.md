Important: As the example I used amazing tutorial: https://medium.com/locust-io-experiments/locust-io-experiments-running-in-docker-cae3c7f9386e GIT repo: https://github.com/karol-brejna-i/docker-locust/
and DockerHub project: https://hub.docker.com/r/grubykarol/locust

Additional sources:
https://wheniwork.engineering/load-testing-with-locust-io-docker-swarm-d78a2602997a
https://docs.locust.io/en/latest/running-locust-docker.html


I wanted the image to:
* use Python 3 (Python 3.8.0-alpine3.9)
* use the latest version of Locust
* take Locust script from the external GitHub project and run them as explained below
 
# Usage 
The image doesn't include locust scripts during build. It assumes, the scripts will be supplied on runtime by mounting a volume (to `/locust` path).

## Building the image
```
docker build -t dominikbaran08/locust .
```
or (if behind a proxy):
```
docker build --build-arg HTTP_PROXY=$http_proxy --build-arg HTTPS_PROXY=$https_proxy -t dominikbaran08/locust . 
```

## Running the image
The image uses the following environment variables to configure its behavior:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
|LOCUST_FILE   | Sets the `--locustfile` option. | locustfile.py | |
|ATTACKED_HOST | The URL to test. Required. | - | http://example.com |
|LOCUST_MODE   | Set the mode to run in. Can be `standalone`, `master` or `slave`. | standalone | master |
|LOCUST_MASTER | Locust master IP or hostname. Required for `slave` mode.| - | 127.0.0.1 |
|LOCUST_MASTER_BIND_PORT | Locust master port. Used in `slave` mode. | 5557 | 6666 |
|LOCUST_OPTS| Additional locust CLI options. | - | "-c 10 -r 10" |


### Standalone

Basic run, with folder (path in $MY_SCRIPTS) holding `locustfile.py`:
```
docker run --rm --name standalone --hostname standalone -e ATTACKED_HOST=http://standalone:8089 -p 8089:8089 -d -v $MY_SCRIPTS:/locust dominikbaran08/locust
```
or, with additional runtime options:
```
docker run --rm --name standalone --hostname standalone -e ATTACKED_HOST=http://standalone:8089 -e "LOCUST_OPTS=--no-web" -p 8089:8089 -d -v $MY_SCRIPTS:/locust dominikbaran08/locust
```

### Master-slave

Run master:
```
docker run --name master --hostname master \
 -p 8089:8089 -p 5557:5557 -p 5558:5558 \
 -v $MY_SCRIPTS:/locust \
 -e ATTACKED_HOST='http://master:8089' \
 -e LOCUST_MODE=master \
 --rm -d dominikbaran08/locust
```

and some slaves:

```
docker run --name slave0 \
 --link master --env NO_PROXY=master \
 -v $MY_SCRIPTS:/locust \
 -e ATTACKED_HOST=http://master:8089 \
 -e LOCUST_MODE=slave \
 -e LOCUST_MASTER=master \
 --rm -d dominikbaran08/locust

docker run --name slave1 \
 --link master --env NO_PROXY=master \
 -v $MY_SCRIPTS:/locust \
 -e ATTACKED_HOST=http://master:8089 \
 -e LOCUST_MODE=slave \
 -e LOCUST_MASTER=master \
 --rm -d dominikbaran08/locust
```


For the real brave, Windows PowerShell version:

Basic run:
```
docker run --rm --name standalone `
 -e ATTACKED_HOST=http://localhost:8089 `
 -v c:\locust-scripts:/locust `
 -p 8089:8089 -d `
 dominikbaran08/locust
```

Run master:
```
docker run --name master --hostname master `
 -p 8089:8089 -p 5557:5557 -p 5558:5558 `
 -v c:\locust-scripts:/locust `
 -e ATTACKED_HOST='http://master:8089' `
 -e LOCUST_MODE=master `
 --rm -d dominikbaran08/locust
```

Run slave:
```
docker run --name slave0 `
 --link master --env NO_PROXY=master `
 -v c:\locust-scripts:/locust `
 -e ATTACKED_HOST=http://master:8089 `
 -e LOCUST_MODE=slave `
 -e LOCUST_MASTER=master `
 --rm -d dominikbaran08/locust
```
