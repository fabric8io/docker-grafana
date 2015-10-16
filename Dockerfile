FROM grafana/grafana:develop
MAINTAINER Jimmi Dyson <jimmidyson@gmail.com>

ENTRYPOINT ["/run.sh"]

ENV GF_AUTH_ANONYMOUS_ENABLED true
ENV GF_DASHBOARDS_JSON_ENABLED true
ENV GF_DASHBOARDS_JSON_PATH /dashboards

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod 777 /var/lib/grafana

ADD run.sh /run.sh
ADD dashboards /dashboards

USER grafana
