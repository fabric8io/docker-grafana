FROM gliderlabs/alpine:3.1
MAINTAINER Jimmi Dyson <jimmidyson@gmail.com>
ENTRYPOINT ["/opt/grafana/grafana"]
EXPOSE 80

ENV GRAFANA_VERSION 1.9.1
ENV INFLUXDB_NAME k8s
ENV GRAFANA_DB_NAME grafana
ENV GRAFANA_DEFAULT_DASHBOARD /dashboard/file/default.json
ENV INFLUXDB_PROTO http
ENV INFLUXDB_USER root
ENV INFLUXDB_PASSWORD root

COPY . /go/src/github.com/jimmidyson/docker-grafana

RUN apk-install go git mercurial ca-certificates openssl tar gzip \
  && mkdir /opt \
  && wget -q -O - http://grafanarel.s3.amazonaws.com/grafana-${GRAFANA_VERSION}.tar.gz | gzip -dc | tar xv -C /opt \
  && mv /opt/grafana-${GRAFANA_VERSION} /opt/grafana \
  && export GOPATH=/go \
  && export PATH=${GOPATH}/bin:${PATH} \
  && cd ${GOPATH}/src/github.com/jimmidyson/docker-grafana/ \
  && go build -ldflags "-X main.Version $(cat VERSION)" -o /opt/grafana/grafana \
  && rm -rf ${GOPATH} \
  && apk del go git mercurial tar gzip \
  && chown nobody:nobody /opt/grafana/

COPY config.js.tmpl /opt/grafana/config.js.tmpl
COPY kubernetes-dashboard.json /opt/grafana/app/dashboards/kubernetes.json

WORKDIR /opt/grafana

USER nobody
