FROM python:3.8.0a2-alpine3.9

COPY docker-entrypoint.sh /

RUN apk add  --no-cache --virtual=.build-dep build-base libffi-dev openssl-dev python-dev curl krb5-dev linux-headers zeromq-dev \
    && apk --no-cache add libzmq \
    && pip install --upgrade pip \
    && pip install --no-cache-dir locustio \
    && apk del .build-dep \
    && chmod +x /docker-entrypoint.sh

RUN  mkdir /locust
WORKDIR /locust
EXPOSE 8089 5557 5558

ENTRYPOINT ["/docker-entrypoint.sh"]
