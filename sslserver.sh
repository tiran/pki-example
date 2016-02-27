#!/bin/sh

openssl s_server \
    -verify 10 \
    -cert certs/server/localhost.crt \
    -key certs/server/localhost.key \
    -pass file:etc/example/server-localhost.passwd \
    -CAfile ca/tls-server-ca-chain.pem \
    -no_ssl2 \
    -no_ssl3 \
    -no_dhe \
    -www \
    -no_ticket \
    $@
