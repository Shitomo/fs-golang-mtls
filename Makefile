SHELL=/bin/bash

ca:
	@openssl req -newkey rsa:2048 \
		-new -nodes -x509 \
		-days 365 \
		-out cert/ca.crt \
		-keyout cert/ca.key \
		-subj "/C=US/ST=Earth/L=Mountain View/O=MegaEase/OU=MegaCloud/CN=localhost"

server-crt:
	@openssl genrsa -out cert/server.key 2048
	@openssl req -new -key cert/server.key -days 365 -out cert/server.csr \
    	-subj "/C=US/ST=Earth/L=Mountain View/O=MegaEase/OU=MegaCloud/CN=localhost" 
	@openssl x509  -req -in cert/server.csr \
    	-extfile <(printf "subjectAltName=DNS:localhost") \
    	-CA cert/ca.crt -CAkey cert/ca.key  \
    	-days 365 -sha256 -CAcreateserial \
    	-out cert/server.crt

client-crt:
	@openssl genrsa -out cert/client.${CLIENT}.key 2048
	@openssl req -new -key cert/client.${CLIENT}.key -days 365 -out cert/client.${CLIENT}.csr \
    	-subj "/C=US/ST=Earth/L=Mountain View/O=$O/OU=$OU/CN=localhost"
	@openssl x509  -req -in cert/client.${CLIENT}.csr \
    	-extfile <(printf "subjectAltName=DNS:localhost") \
    	-CA cert/ca.crt -CAkey cert/ca.key -out cert/client.${CLIENT}.crt -days 365 -sha256 -CAcreateserial

fake-client-crt:
	@openssl req -newkey rsa:2048 \
		-new -nodes -x509 \
		-days 365 \
		-out cert/fake-ca.crt \
		-keyout cert/fake-ca.key \
		-subj "/C=US/ST=Earth/L=Mountain View/O=MegaEase/OU=MegaCloud/CN=localhost"
	@openssl genrsa -out cert/client.${CLIENT}.key 2048
	@openssl req -new -key cert/client.${CLIENT}.key -days 365 -out cert/client.${CLIENT}.csr \
    	-subj "/C=US/ST=Earth/L=Mountain View/O=$O/OU=$OU/CN=localhost"
	@openssl x509  -req -in cert/client.${CLIENT}.csr \
    	-extfile <(printf "subjectAltName=DNS:localhost") \
    	-CA cert/fake-ca.crt -CAkey cert/fake-ca.key -out cert/client.${CLIENT}.crt -days 365 -sha256 -CAcreateserial


run-server:
	@go run server/server.go

run-client:
	@go run client/client.go -client ${CLIENT}
