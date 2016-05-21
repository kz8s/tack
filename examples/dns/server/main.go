package main

import (
	"encoding/json"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	bytes, err := json.Marshal(r.URL.Query())
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.Write(bytes)
}

func main() {
	http.HandleFunc("/ping", handler)
	http.ListenAndServe(":8080", nil)
}
