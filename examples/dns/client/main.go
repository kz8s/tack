package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
)

func checkServiceAddress(domain string) []string {

	addrs, err := net.LookupHost(domain)
	if err != nil {
		log.Fatalln(err)
	}
	return addrs
}

func getServerResponse(url string) string {

	resp, err := http.Get(url)
	if err != nil {
		log.Fatalf("failed to GET: %s: %v", url, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		log.Fatalf("failed to GET: %s: invalid status code: %d", url, resp.StatusCode)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}

	return string(body)
}

func main() {

	if len(os.Args) != 2 {
		log.Fatalln("Usage: ./client [ping url]")
	}

	arg := os.Args[1]

	pingURL, err := url.Parse(arg)
	if err != nil {
		log.Fatalln(err)
	}

	if pingURL.Host == "" {
		log.Fatalf("No host in url: %s", arg)
	}

	addrs := checkServiceAddress(pingURL.Host)
	fmt.Println(addrs)

	resp := getServerResponse(arg)
	log.Println(resp)
}
