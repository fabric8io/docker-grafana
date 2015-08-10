FROM centos:7
MAINTAINER Jimmi Dyson <jimmidyson@gmail.com>
ENTRYPOINT ["/usr/sbin/grafana-server", "--homepath=/usr/share/grafana", "--config=/etc/grafana/grafana.ini"]
EXPOSE 3000

ENV GRAFANA_VERSION 2.1.0
ENV GF_LOG_MODE console
ENV GF_PATHS_DATA /var/lib/grafana
ENV GF_PATHS_LOGS /var/lib/grafana
ENV GF_AUTH_ANONYMOUS_ENABLED true
ENV GF_AUTH_PROXY_ENABLED true

RUN rpm --import https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana && \
    yum install -y https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VERSION}-1.x86_64.rpm && \
    sed -i 's/mode.*=.*$/log.mode = console/' /usr/share/grafana/conf/defaults.ini && \
    chmod 777 /var/lib/grafana && \
    curl -L https://github.com/grafana/grafana-plugins/archive/master.tar.gz | tar xvz -C /usr/share/grafana/public/app/plugins/datasource/ --strip-components=2 grafana-plugins-master/datasources/prometheus

VOLUME /var/lib/grafana
USER grafana
