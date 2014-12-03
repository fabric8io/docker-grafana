package main

import (
	"log"
	"net/http"
	"os"
	"text/template"
)

func main() {
	t, _ := template.ParseFiles("config.js.tmpl")

	file, err := os.Create("config.js") // For read access.
	if err != nil {
		log.Fatal(err)
	}
	t.Execute(file, nil)
	file.Close()

	fs := http.FileServer(http.Dir("."))
	http.Handle("/", fs)

	log.Println("Listening...")
	http.ListenAndServe(":3000", nil)
}
