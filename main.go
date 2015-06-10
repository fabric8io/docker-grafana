package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
	"text/template"
)

type Context struct {
}

func (c *Context) Env() map[string]string {
	env := make(map[string]string)
	for _, i := range os.Environ() {
		sep := strings.Index(i, "=")
		env[i[0:sep]] = i[sep+1:]
	}
	return env
}

func main() {
	influxDbUrl := os.Getenv("INFLUXDB_URL")
	if len(influxDbUrl) == 0 && len(os.Getenv("INFLUXDB_SERVICE_NAME")) > 0 {
		influxDbUrl = "${INFLUXDB_PROTO}://${" +
			os.Getenv("INFLUXDB_SERVICE_NAME") + "_SERVICE_HOST}:${" +
			os.Getenv("INFLUXDB_SERVICE_NAME") + "_SERVICE_PORT}/"
	} else {
		log.Println("Using ", os.Getenv("INFLUXDB_URL"))
	}
	os.Setenv("INFLUXDB_URL", "")
	influxDbUrl = os.ExpandEnv(influxDbUrl)

	if url, err := url.Parse(influxDbUrl); err == nil {
		http.Handle("/db/", httputil.NewSingleHostReverseProxy(url))
		log.Println("Using reverse proxy to ", url)
	} else {
		log.Fatal(err)
	}

	if len(os.Getenv("INFLUXDB_USER")) == 0 {
		os.Setenv("INFLUXDB_USER", "")
	}
	if len(os.Getenv("INFLUXDB_PASSWORD")) == 0 {
		os.Setenv("INFLUXDB_PASSWORD", "")
	}

	t, _ := template.ParseFiles("config.js.tmpl")

	file, err := os.Create("config.js")
	if err != nil {
		log.Fatal(err)
	}
	t.Execute(file, &Context{})
	file.Close()

	fs := http.FileServer(http.Dir("."))
	http.Handle("/", fs)

	log.Println("Listening...")
	log.Fatal(http.ListenAndServe(":3000", nil))
}
