package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	mux := http.NewServeMux()

	mux.Handle("/", http.FileServer(http.Dir("/ui")))

	port := os.Getenv("SALEX_TODO_APP_PORT")

	if port == "" {
		log.Fatal("SALEX_TODO_APP_PORT is not set")
	}

	//	mux.Handle("/", &controller.HelloHandler{})
	fmt.Printf("Starting service on port %s", port)
	http.ListenAndServe(fmt.Sprintf(":%s", port), mux)
}
