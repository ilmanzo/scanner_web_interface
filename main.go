package main

import (
	// We don't have to use a blank import anymore,
	// since we're using embed.FS
	embed "embed"
	"log"
	"net/http"
	"os/exec"
)

//go:embed index.html
var indexPage []byte

//go:embed assets/*
var assets embed.FS

func RunScanCommand(email string) string {
	cmd, err := exec.Command("/bin/bash", "/usr/local/bin/scan.sh", email).Output()
	if err != nil {
		log.Printf("error in running scan command: %s", err)
	}
	output := string(cmd)
	return output
}

func scanner(w http.ResponseWriter, r *http.Request) {
	email := r.URL.Query().Get("email")
	log.Printf("sending email to: %s\n", email)
	output := RunScanCommand(email)
	log.Printf("Output: %s\n", output)
	http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
}

func main() {
	assetsFs := http.FileServer(http.FS(assets))

	mux := http.NewServeMux()
	mux.Handle("/assets/", assetsFs)
	mux.HandleFunc("/scan/", scanner)
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write(indexPage)
	})
	log.Println("Listening on :8000")
	err := http.ListenAndServe(":8000", mux)

	if err != nil {
		log.Fatal(err)
	}
}
