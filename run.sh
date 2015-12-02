#!/bin/bash

pid=0

term_handler() {
  pkill -TERM $pid
  exit
}

trap 'term_handler' SIGINT

HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"

GRAFANA_USER=${GRAFANA_USER:-admin}
GRAFANA_PASSWD=${GRAFANA_PASSWD:-admin}

PROMETHEUS_ADDRESS=${PROMETHEUS_ADDRESS:-'http://prometheus:9090'}

DASHBOARD_LOCATION=${DASHBOARD_LOCATION:-'/dashboards'}

echo "Starting Grafana in the background"
/usr/sbin/grafana-server \
  --homepath=/usr/share/grafana \
  config=/etc/grafana/grafana.ini \
  cfg:default.paths.data=/var/lib/grafana \
  cfg:default.log.mode=console &
pid=$!

echo "Waiting for Grafana to start..."
until $(curl --fail --output /dev/null --silent http://${GRAFANA_USER}:${GRAFANA_PASSWD}@localhost:3000/api/org); do
  printf "."
  sleep 1
done
echo "Grafana is up and running."

if [ ! -f /var/lib/grafana/.configured ]; then
  echo "Creating default prometheus datasource..."
  curl -i -XPOST -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" "http://${GRAFANA_USER}:${GRAFANA_PASSWD}@localhost:3000/api/datasources" -d '
  { 
    "name": "kubernetes-prometheus",
    "type": "prometheus",
    "access": "proxy",
    "isDefault": true,
    "url": "'"${PROMETHEUS_ADDRESS}"'"
  }'

  touch /var/lib/grafana/.configured
  echo ""
fi

wait $pid
