# Grafana Docker Image

This image runs [Grafana](http://grafana.org) listening on port 3000.
The image weighs in at very lightweight ~12MB & requires only ~4MB RAM
to run as it uses a very small golang binary to serve the static files.

The Grafana `config.js` is configured via the following environment
variables:

* `INFLUXDB_URL` - the URL to the InfluxDB instance you want to connect to
* `INFLUXDB_SERVICE_NAME` - the name of the Kubernetes InfluxDB service (default: INFLUXDB)
* `INFLUXDB_PROTO` - the protocol to use (default: `http`)
* `INFLUXDB_NAME` - the name of the InfluxDB database to query (default: `k8s`)
* `GRAFANA_DB_NAME` - the name of the InfluxDB database to use for Grafana dashboard storage (default: `grafana`)
* `INFLUXDB_USER` - the username to connect with (default: `root`)
* `INFLUXDB_PASSWORD` - the password to connect with (default: `root`)

## Running in Kubernetes/OpenShift3

`INFLUXDB_URL` environment variable can itself contain environment variables
which will be expanded at runtime to populate the `config.js`. This is very
useful in a [Kubernetes](http://kubernetes.io/) environment where you might
have an InfluxDB service running. For example, if you have an InfluxDB service
running called "InfluxDB", then you can use the following configuration to run
this Grafana image:

```yaml
containers:
  - name: grafana-image
    image: jimmidyson/grafana:latest
    ports:
      - name: grafana-port
        containerPort: 3000
    env:
      - name: INFLUXDB_URL
        value: http://${INFLUX_MASTER_SERVICE_HOST}:${INFLUX_MASTER_SERVICE_PORT}
      - name: INFLUXDB_NAME
        value: k8s
      - name: INFLUXDB_USER
        value: root
      - name: INFLUXDB_PASSWORD
        value: root
```
