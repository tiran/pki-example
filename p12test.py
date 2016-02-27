#!/usr/bin/python
from OpenSSL import crypto

def pcert(cert):
    print(cert.get_subject(), cert.get_issuer())

with open('certs/client/exampleuser.p12', 'rb') as f:
    data = f.read()

p12 = crypto.load_pkcs12(data, 'Secret123')
pcert(p12.get_certificate())
for cert in p12.get_ca_certificates():
    pcert(cert)

