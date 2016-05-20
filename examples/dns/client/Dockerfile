FROM kz8s/golang
MAINTAINER jono@kz8s.io

WORKDIR /go/src/app
COPY main.go /go/src/app

RUN set -eux &&\
  go build -o client

ENTRYPOINT [ "./client" ]
