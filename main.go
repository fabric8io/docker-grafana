package main

import (
	"log"
	"net/http"
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
	os.Setenv("INFLUXDB_URL", os.ExpandEnv(os.Getenv("INFLUXDB_URL")))

	log.Println("Using ", os.Getenv("INFLUXDB_URL"))

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
	http.ListenAndServe(":3000", nil)
}
