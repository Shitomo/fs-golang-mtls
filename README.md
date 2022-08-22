# fs-golang-mtls

## setup

```
make ca
make server-crt
CLIENT=<client name> make client-crt
make fake-client-crt
```

## run

### server

```
make run-server
```

### client

real client (success)

```
CLIENT=<client name> make run-client
```

fail client (fail)

```
CLIENT=fake make run-client
```
