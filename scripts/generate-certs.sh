#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="$(dirname "$0")/../certs"

mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

echo "[+] Generating CA..."

openssl genrsa \
    -out ca-key.pem \
    4096

openssl req \
    -x509 \
    -new \
    -nodes \
    -key ca-key.pem \
    -sha256 \
    -days 3650 \
    -out ca-cert.pem \
    -subj "/C=LT/O=OpenConnect Lab/CN=OpenConnect Lab CA"


echo "[+] Generating server key..."

openssl genrsa \
    -out server-key.pem \
    2048


echo "[+] Generating server CSR..."

openssl req \
    -new \
    -key server-key.pem \
    -out server.csr \
    -subj "/C=LT/O=OpenConnect Lab/CN=192.168.1.2"


cat > server-ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=IP:192.168.1.2
EOF


echo "[+] Signing server certificate..."

openssl x509 \
    -req \
    -in server.csr \
    -CA ca-cert.pem \
    -CAkey ca-key.pem \
    -CAcreateserial \
    -out server-cert.pem \
    -days 825 \
    -sha256 \
    -extfile server-ext.cnf


echo "[+] Generating router client key..."

openssl genrsa \
    -out router-client-key.pem \
    2048


echo "[+] Generating router client CSR..."

openssl req \
    -new \
    -key router-client-key.pem \
    -out router-client.csr \
    -subj "/C=LT/O=OpenConnect Lab/CN=router-client"


cat > client-ext.cnf <<EOF
basicConstraints=CA:FALSE
keyUsage=digitalSignature
extendedKeyUsage=clientAuth
EOF


echo "[+] Signing router client certificate..."

openssl x509 \
    -req \
    -in router-client.csr \
    -CA ca-cert.pem \
    -CAkey ca-key.pem \
    -CAcreateserial \
    -out router-client-cert.pem \
    -days 825 \
    -sha256 \
    -extfile client-ext.cnf


echo
echo "[+] Certificates generated:"
echo

ls -lh \
    ca-cert.pem \
    server-cert.pem \
    server-key.pem \
    router-client-cert.pem \
    router-client-key.pem

echo
echo "[!] Keep ca-key.pem and router-client-key.pem private."
