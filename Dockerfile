FROM busybox:latest
MAINTAINER Jimmi Dyson <jimmidyson@gmail.com>

ENV GRAFANA_VERSION 1.9.0

ADD ./stage/grafana /opt/grafana/grafana
ADD config.js.tmpl /opt/grafana/config.js.tmpl

RUN wget -q -O - http://grafanarel.s3.amazonaws.com/grafana-${GRAFANA_VERSION}.tar.gz | gzip -dc | tar xv -C /opt && \
    mv /opt/grafana-${GRAFANA_VERSION}/* /opt/grafana

WORKDIR /opt/grafana

EXPOSE 3000

ENTRYPOINT ["/opt/grafana/grafana"]
CMD []
