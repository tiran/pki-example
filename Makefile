# # Authors:
#   Christian Heimes <christian@python.org>
#
# Copyright (C) 2015 Christian Heimes
#
#
# This make file is dowdy. My make fu is weak.
#

.PHONY=all examples
all: root-ca tls-server-ca tls-client-ca email-ca
examples: all certs/client/exampleuser.p12 certs/server/localhost-bundle.pem

# =======================================================================

.PHONY=root-ca

ROOT_CA_FILES= \
    ca/root-ca/private \
    ca/root-ca/db/root-ca.db \
    ca/root-ca/db/root-ca.db.attr \
    ca/root-ca/db/root-ca.crt.srl \
    ca/root-ca/db/root-ca.crl.srl \

root-ca: \
    $(ROOT_CA_FILES) \
    ca/root-ca.crt \
    crl/root-ca.crl \
    ca/root-ca.cer

crl:
	mkdir $@

ca/root-ca/private:
	mkdir -p -m700 $@

ca/root-ca/db:
	mkdir -p $@

ca/root-ca/db/root-ca.db: ca/root-ca/db
	@touch $@

ca/root-ca/db/root-ca.db.attr: ca/root-ca/db
	@touch $@

ca/root-ca/db/root-ca.crt.srl: ca/root-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/root-ca/db/root-ca.crl.srl: ca/root-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/root-ca/private/root-ca.key: | $(ROOT_CA_FILES)
	openssl req -new \
	    -config etc/root-ca.conf \
	    -out ca/root-ca.csr \
	    -keyout $@ \
	    -passout file:etc/root-ca.password

ca/root-ca.crt: | ca/root-ca/private/root-ca.key
	openssl ca -selfsign \
	    -config etc/root-ca.conf \
	    -in ca/root-ca.csr \
	    -out $@ \
	    -extensions root_ca_ext \
	    -enddate 20301231235959Z \
	    -batch \
	    -passin file:etc/root-ca.password

ca/root-ca.cer: ca/root-ca.crt
	openssl x509 \
	    -in ca/root-ca.crt \
	    -out $@ \
	    -outform DER

crl/root-ca.crl: | ca/root-ca.crt crl
	openssl ca -gencrl \
	    -config etc/root-ca.conf \
	    -out $@ \
	    -passin file:etc/root-ca.password

	openssl crl \
	    -in $@ \
	    -out $@ \
	    -outform DER


# =======================================================================

.PHONY=tls-server-ca

TLS_SERVER_CA_FILES= \
    ca/tls-server-ca/private \
    ca/tls-server-ca/db/tls-server-ca.db \
    ca/tls-server-ca/db/tls-server-ca.db.attr \
    ca/tls-server-ca/db/tls-server-ca.crt.srl \
    ca/tls-server-ca/db/tls-server-ca.crl.srl \
    certs/server \
    ca/root-ca.crt

certs/server:
	mkdir -p $@

tls-server-ca: \
    $(TLS_SERVER_CA_FILES) \
    ca/tls-server-ca.crt \
    ca/tls-server-ca.cer \
    crl/tls-server-ca.crl \
    ca/tls-server-ca-chain.pem

ca/tls-server-ca/private:
	mkdir -p -m700 $@

ca/tls-server-ca/db:
	mkdir -p $@

ca/tls-server-ca/db/tls-server-ca.db: ca/tls-server-ca/db
	@touch $@

ca/tls-server-ca/db/tls-server-ca.db.attr: ca/tls-server-ca/db
	@touch $@

ca/tls-server-ca/db/tls-server-ca.crt.srl: ca/tls-server-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/tls-server-ca/db/tls-server-ca.crl.srl: ca/tls-server-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/tls-server-ca/private/tls-server-ca.key: | $(TLS_SERVER_CA_FILES)
	openssl req -new \
	    -config etc/tls-server-ca.conf \
	    -out ca/tls-server-ca.csr \
	    -keyout $@ \
	    -passout file:etc/tls-server-ca.password

ca/tls-server-ca.crt: | ca/tls-server-ca/private/tls-server-ca.key
	openssl ca \
	    -config etc/root-ca.conf \
	    -in ca/tls-server-ca.csr \
	    -out $@ \
	    -extensions signing_ca_ext \
	    -batch \
	    -passin file:etc/root-ca.password

ca/tls-server-ca.cer: ca/tls-server-ca.crt
	openssl x509 \
	    -in ca/tls-server-ca.crt \
	    -out $@ \
	    -outform DER

crl/tls-server-ca.crl: | ca/tls-server-ca.crt crl
	openssl ca -gencrl \
	    -config etc/tls-server-ca.conf \
	    -out $@ \
	    -passin file:etc/tls-server-ca.password

	openssl crl \
	    -in $@ \
	    -out $@ \
	    -outform DER

ca/tls-server-ca-chain.pem: ca/tls-server-ca.crt ca/root-ca.crt
	cat ca/tls-server-ca.crt ca/root-ca.crt > \
	    $@

# =======================================================================

.PHONY=tls-client-ca

TLS_CLIENT_CA_FILES= \
    ca/tls-client-ca/private \
    ca/tls-client-ca/db/tls-client-ca.db \
    ca/tls-client-ca/db/tls-client-ca.db.attr \
    ca/tls-client-ca/db/tls-client-ca.crt.srl \
    ca/tls-client-ca/db/tls-client-ca.crl.srl \
    certs/client \
    ca/root-ca.crt

certs/client:
	mkdir -p $@

tls-client-ca: \
    $(TLS_CLIENT_CA_FILES) \
    ca/tls-client-ca.crt \
    ca/tls-client-ca.cer \
    crl/tls-client-ca.crl \
    ca/tls-client-ca-chain.pem

ca/tls-client-ca/private:
	mkdir -p -m700 $@

ca/tls-client-ca/db:
	mkdir -p $@

ca/tls-client-ca/db/tls-client-ca.db: ca/tls-client-ca/db
	@touch $@

ca/tls-client-ca/db/tls-client-ca.db.attr: ca/tls-client-ca/db
	@touch $@

ca/tls-client-ca/db/tls-client-ca.crt.srl: ca/tls-client-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/tls-client-ca/db/tls-client-ca.crl.srl: ca/tls-client-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/tls-client-ca/private/tls-client-ca.key: | $(TLS_CLIENT_CA_FILES)
	openssl req -new \
	    -config etc/tls-client-ca.conf \
	    -out ca/tls-client-ca.csr \
	    -keyout $@ \
	    -passout file:etc/tls-client-ca.password

ca/tls-client-ca.crt: | ca/tls-client-ca/private/tls-client-ca.key
	openssl ca \
	    -config etc/root-ca.conf \
	    -in ca/tls-client-ca.csr \
	    -out $@ \
	    -extensions signing_ca_ext \
	    -batch \
	    -passin  file:etc/root-ca.password

ca/tls-client-ca.cer: ca/tls-client-ca.crt
	openssl x509 \
	    -in ca/tls-client-ca.crt \
	    -out $@ \
	    -outform DER

crl/tls-client-ca.crl: | ca/tls-client-ca.crt crl
	openssl ca -gencrl \
	    -config etc/tls-client-ca.conf \
	    -out $@ \
	    -passin file:etc/tls-client-ca.password

	openssl crl \
	    -in $@ \
	    -out $@ \
	    -outform DER

ca/tls-client-ca-chain.pem: ca/tls-client-ca.crt ca/root-ca.crt
	cat ca/tls-client-ca.crt ca/root-ca.crt > \
	    $@

# =======================================================================

.PHONY=email-ca

EMAIL_CA_FILES= \
    ca/email-ca/private \
    ca/email-ca/db/email-ca.db \
    ca/email-ca/db/email-ca.db.attr \
    ca/email-ca/db/email-ca.crt.srl \
    ca/email-ca/db/email-ca.crl.srl \
    certs/email \
    ca/root-ca.crt

certs/email:
	mkdir -p $@

email-ca: \
    $(EMAIL_CA_FILES) \
    ca/email-ca.crt \
    ca/email-ca.cer \
    crl/email-ca.crl \
    ca/email-ca-chain.pem

ca/email-ca/private:
	mkdir -p -m700 $@

ca/email-ca/db:
	mkdir -p $@

ca/email-ca/db/email-ca.db: ca/email-ca/db
	@touch $@

ca/email-ca/db/email-ca.db.attr: ca/email-ca/db
	@touch $@

ca/email-ca/db/email-ca.crt.srl: ca/email-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/email-ca/db/email-ca.crl.srl: ca/email-ca/db
	@if [ ! -f $@ ]; then echo 01 > $@; fi

ca/email-ca/private/email-ca.key: | $(EMAIL_CA_FILES)
	openssl req -new \
	    -config etc/email-ca.conf \
	    -out ca/email-ca.csr \
	    -keyout $@ \
	    -passout file:etc/email-ca.password

ca/email-ca.crt: | ca/email-ca/private/email-ca.key
	openssl ca \
	    -config etc/root-ca.conf \
	    -in ca/email-ca.csr \
	    -out $@ \
	    -extensions signing_ca_ext \
	    -batch \
	    -passin file:etc/root-ca.password

ca/email-ca.cer: ca/email-ca.crt
	openssl x509 \
	    -in ca/email-ca.crt \
	    -out $@ \
	    -outform DER

crl/email-ca.crl: | ca/email-ca.crt crl
	openssl ca -gencrl \
	    -config etc/email-ca.conf \
	    -out $@ \
	    -passin file:etc/email-ca.password

	openssl crl \
	    -in $@ \
	    -out $@ \
	    -outform DER

ca/email-ca-chain.pem: ca/email-ca.crt ca/root-ca.crt
	cat ca/email-ca.crt ca/root-ca.crt > \
	    $@

# =======================================================================

certs/client/exampleuser.key:
	openssl req -new \
	    -config etc/example/client-exampleuser.conf \
	    -out certs/client/exampleuser.csr \
	    -keyout $@ \
	    -batch \
	    -passout file:etc/example/client-exampleuser.passwd

certs/client/exampleuser.crt: | certs/client/exampleuser.key ca/tls-client-ca.crt
	openssl ca \
	    -config etc/tls-client-ca.conf \
	    -in certs/client/exampleuser.csr \
	    -out $@ \
	    -policy extern_pol \
	    -extensions client_ext \
	    -batch \
	    -passin file:etc/tls-client-ca.password

	openssl verify -verbose \
	    -purpose sslclient \
	    -CAfile ca/root-ca.crt \
	    -untrusted ca/tls-client-ca.crt \
	    $@

certs/client/exampleuser.p12: | certs/client/exampleuser.crt
	openssl pkcs12 -export \
	    -name "Example User" \
	    -inkey certs/client/exampleuser.key \
	    -in certs/client/exampleuser.crt \
	    -caname "Acme TLS Client CA" \
	    -caname "Acme TLS Root CA" \
	    -CAfile ca/tls-client-ca-chain.pem \
	    -chain \
	    -out $@ \
	    -passin file:etc/example/client-exampleuser.passwd \
	    -passout file:etc/example/client-exampleuser.export-passwd \

	openssl pkcs12 -info \
	    -in $@ \
	    -nokeys \
	    -passin file:etc/example/client-exampleuser.export-passwd

# =======================================================================

certs/server/localhost.key:
	openssl req -new \
	    -config etc/example/server-localhost.conf \
	    -out certs/server/localhost.csr \
	    -keyout $@ \
	    -batch \
	    -passout file:etc/example/server-localhost.passwd

certs/server/localhost.crt: | certs/server/localhost.key ca/tls-server-ca.crt
	openssl ca \
	    -config etc/tls-server-ca.conf \
	    -in certs/server/localhost.csr \
	    -out $@ \
	    -policy extern_pol \
	    -extensions server_ext \
	    -batch \
	    -passin file:etc/tls-server-ca.password

	openssl verify -verbose \
	    -purpose sslserver \
	    -CAfile ca/root-ca.crt \
	    -untrusted ca/tls-server-ca.crt \
	    $@

certs/server/localhost-bundle.pem: | certs/server/localhost.crt
	openssl pkey \
	    -in certs/server/localhost.key \
	    -passin file:etc/example/server-localhost.passwd \
	    -out $@

	cat \
	    certs/server/localhost.crt \
	    ca/tls-server-ca.crt \
	    >> $@



# =======================================================================

.PHONY=clean
clean:
	rm -rf ca certs crl
