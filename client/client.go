package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

func main() {

	name := flag.String("client", "a", "client name")
	flag.Parse()

	// client cert
	clientCert := fmt.Sprintf("./cert/client.%s.crt", *name)
	clientKey := fmt.Sprintf("./cert/client.%s.key", *name)
	certificate, err := tls.LoadX509KeyPair(clientCert, clientKey)
	if err != nil {
		log.Fatalf("could not load certificate: %v", err)
	}

	// root cert
	cert, err := ioutil.ReadFile("./cert/ca.crt")
	if err != nil {
		log.Fatalf("could not open certificate file: %v", err)
	}
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(cert)

	client := http.Client{
		Timeout: time.Minute * 3,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs:      caCertPool,
				Certificates: []tls.Certificate{certificate},
			},
		},
	}

	r, err := client.Get("https://localhost:8443/hello")
	if err != nil {
		log.Fatalf("error making get request: %v", err)
	}

	// Read the response body
	defer r.Body.Close()
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Fatalf("error reading response: %v", err)
	}

	// Print the response body to stdout
	fmt.Printf("%s\n", body)
}
