FROM python:3.6-alpine3.7

COPY docker-entrypoint.sh /

RUN    apk --no-cache add --virtual=.build-dep build-base \
    && pip install -U setuptools pip
    && apk --no-cache add libzmq \
    && pip install --no-cache-dir locustio \
    && apk del .build-dep \
    && chmod +x /docker-entrypoint.sh

RUN  mkdir /locust
WORKDIR /locust
EXPOSE 8089 5557 5558

ENTRYPOINT ["/docker-entrypoint.sh"]
