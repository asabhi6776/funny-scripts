#!/bin/bash
set -e

echo "=== Self-Signed CA and Wildcard Certificate Generator ==="

# === User Inputs ===
read -p "Enter Root CA name (e.g. 'Root CA'): " CA_NAME
read -p "Enter Country Code (e.g. IN): " COUNTRY
read -p "Enter State/Province (e.g. Karnataka): " STATE
read -p "Enter Locality/City (e.g. Bangalore): " LOCALITY
read -p "Enter Organization (e.g. Infinity): " ORG
read -p "Enter Organizational Unit (e.g. Helios): " ORG_UNIT
read -p "Enter Domain (e.g. *.infinitygate.fun): " DOMAIN
read -p "Enter RSA Key Size [2048/3072/4096] (default 2048): " KEY_SIZE
read -p "Enter CA validity in days (default 3650 ~10 years): " DAYS_CA
read -p "Enter Certificate validity in days (default 825 ~2 years): " DAYS_CERT

# === Defaults ===
KEY_SIZE=${KEY_SIZE:-2048}
DAYS_CA=${DAYS_CA:-3650}
DAYS_CERT=${DAYS_CERT:-825}

# === Output files ===
CA_KEY="ca.key"
CA_CERT="ca.crt"
CA_SERIAL="ca.srl"

WILDCARD_KEY="wildcard.key"
WILDCARD_CSR="wildcard.csr"
WILDCARD_CERT="wildcard.crt"
WILDCARD_CNF="wildcard.cnf"

echo ""
echo "[*] Using configuration:"
echo "CA Name: $CA_NAME"
echo "Domain: $DOMAIN"
echo "RSA Key Size: $KEY_SIZE"
echo "CA Validity: $DAYS_CA days"
echo "Cert Validity: $DAYS_CERT days"
echo ""

# === 1. Create CA private key ===
echo "[*] Generating CA private key..."
openssl genrsa -out $CA_KEY $KEY_SIZE

# === 2. Create self-signed CA certificate ===
echo "[*] Creating CA certificate..."
openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days $DAYS_CA -out $CA_CERT \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$CA_NAME"

# === 3. Generate private key for wildcard cert ===
echo "[*] Generating wildcard private key..."
openssl genrsa -out $WILDCARD_KEY $KEY_SIZE

# === 4. Create OpenSSL config for SAN ===
echo "[*] Creating OpenSSL config..."
cat > $WILDCARD_CNF <<EOF
[req]
default_bits       = $KEY_SIZE
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
C  = $COUNTRY
ST = $STATE
L  = $LOCALITY
O  = $ORG
OU = $ORG_UNIT
CN = $DOMAIN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = ${DOMAIN#*.}
EOF

# === 5. Create CSR ===
echo "[*] Generating CSR..."
openssl req -new -key $WILDCARD_KEY -out $WILDCARD_CSR -config $WILDCARD_CNF

# === 6. Sign CSR with CA ===
echo "[*] Signing certificate with CA..."
openssl x509 -req -in $WILDCARD_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial \
  -out $WILDCARD_CERT -days $DAYS_CERT -sha256 -extfile $WILDCARD_CNF -extensions req_ext

# === 7. Verify certificate ===
echo "[*] Verifying certificate..."
openssl x509 -in $WILDCARD_CERT -text -noout | grep "Subject:\|Issuer:\|DNS"

echo ""
echo "[+] Done!"
echo "Generated files:"
ls -1 $CA_KEY $CA_CERT $WILDCARD_KEY $WILDCARD_CERT

