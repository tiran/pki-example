#!/bin/sh

openssl s_client \
    -verify 10 \
    -verify_return_error \
    -cert certs/client/exampleuser.crt \
    -key certs/client/exampleuser.key \
    -pass file:etc/example/client-exampleuser.passwd \
    -CAfile ca/tls-client-ca-chain.pem \
    -tls1_2 \
    -servername localhost \
    $@
