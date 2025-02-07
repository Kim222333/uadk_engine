#!/bin/bash

set -x
sudo chmod 666 /dev/hisi_*

TEST_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

version=$(openssl version)
echo $version

# Extract the major version number (e.g., "3") from the version string
major_version=$(echo $version | awk -F'[ .]' '{print $2}')
echo "OpenSSL major version is "$major_version

# Check if the major version is equal to or greater than 3
if ((major_version >= 3)); then
	engine_id="$TEST_SCRIPT_DIR/../src/.libs/uadk_provider.so"
	digest_algs=$(openssl list -provider $engine_id -digest-algorithms)
	cipher_algs=$(openssl list -provider $engine_id -cipher-algorithms)
	signature_algs=$(openssl list -provider $engine_id -signature-algorithms)
fi

if [[ $digest_algs =~ "uadk_provider" ]]; then
	echo "uadk_provider testing digest"
	openssl speed -provider $engine_id -evp md5
	openssl speed -provider $engine_id -evp sm3
	openssl speed -provider $engine_id -evp sha1
	openssl speed -provider $engine_id -evp sha2-224
	openssl speed -provider $engine_id -evp sha2-256
	openssl speed -provider $engine_id -evp sha2-384
	openssl speed -provider $engine_id -evp sha2-512

	openssl speed -provider $engine_id -async_jobs 1 -evp md5
	openssl speed -provider $engine_id -async_jobs 1 -evp sm3
	openssl speed -provider $engine_id -async_jobs 1 -evp sha1
	openssl speed -provider $engine_id -async_jobs 1 -evp sha2-224
	openssl speed -provider $engine_id -async_jobs 1 -evp sha2-256
	openssl speed -provider $engine_id -async_jobs 1 -evp sha2-384
	openssl speed -provider $engine_id -async_jobs 1 -evp sha2-512
fi

if [[ $cipher_algs =~ "uadk_provider" ]]; then
	echo "uadk_provider testing cipher"
	openssl speed -provider $engine_id -evp aes-128-cbc
	openssl speed -provider $engine_id -evp aes-192-cbc
	openssl speed -provider $engine_id -evp aes-256-cbc
	openssl speed -provider $engine_id -evp aes-128-ecb
	openssl speed -provider $engine_id -evp aes-192-ecb
	openssl speed -provider $engine_id -evp aes-256-ecb
	openssl speed -provider $engine_id -evp aes-128-xts
	openssl speed -provider $engine_id -evp aes-256-xts
	openssl speed -provider $engine_id -evp sm4-cbc
	openssl speed -provider $engine_id -evp sm4-ecb
	openssl speed -provider $engine_id -evp des-ede3-cbc
	openssl speed -provider $engine_id -evp des-ede3-ecb

	openssl speed -provider $engine_id -async_jobs 1 -evp aes-128-cbc
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-192-cbc
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-256-cbc
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-128-ecb
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-192-ecb
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-256-ecb
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-128-xts
	openssl speed -provider $engine_id -async_jobs 1 -evp aes-256-xts
	openssl speed -provider $engine_id -async_jobs 1 -evp sm4-cbc
	openssl speed -provider $engine_id -async_jobs 1 -evp sm4-ecb
	openssl speed -provider $engine_id -async_jobs 1 -evp des-ede3-cbc
	openssl speed -provider $engine_id -async_jobs 1 -evp des-ede3-ecb
fi

if [[ $signature_algs =~ "uadk_provider" ]]; then
	echo "uadk_provider testing rsa"
	openssl speed -provider $engine_id rsa1024
	openssl speed -provider $engine_id rsa2048
	openssl speed -provider $engine_id rsa4096
	openssl speed -provider $engine_id -async_jobs 1 rsa1024
	openssl speed -provider $engine_id -async_jobs 1 rsa2048
	openssl speed -provider $engine_id -async_jobs 1 rsa4096

	openssl genrsa -out prikey.pem -provider $engine_id 1024
	openssl rsa -in prikey.pem -pubout -out pubkey.pem -provider $engine_id -provider default
	echo "Content to be encrypted" > plain.txt

	openssl pkeyutl -encrypt -in plain.txt -inkey pubkey.pem -pubin -out enc.txt \
	-pkeyopt rsa_padding_mode:pkcs1 -provider uadk_provider -provider default

	openssl pkeyutl -decrypt -in enc.txt -inkey prikey.pem -out dec.txt \
        -pkeyopt rsa_padding_mode:pkcs1 -provider $engine_id -provider default
fi

if [[ $version =~ "1.1.1" ]]; then
	echo "openssl 1.1.1"
	engine_id="$TEST_SCRIPT_DIR/../src/.libs/uadk_engine.so"
	algs=$(openssl engine -c $engine_id)
	echo $algs
fi

#digest
if [[ $algs =~ "MD5" ]]; then
	echo "testing MD5"
	openssl speed -engine $engine_id -evp md5
	openssl speed -engine $engine_id -async_jobs 1 -evp md5
fi

if [[ $algs =~ "SM3" ]]; then
	echo "testing SM3"
	openssl speed -engine $engine_id -evp sm3
	openssl speed -engine $engine_id -async_jobs 1 -evp sm3
fi

if [[ $algs =~ "SM2" ]]; then
	echo "testing SM2"
	openssl speed -engine $engine_id -evp sm2
	openssl speed -engine $engine_id -async_jobs 1 -evp sm2
fi

if [[ $algs =~ "SHA" ]]; then
	echo "testing SHA"
	openssl speed -engine $engine_id -evp sha1
	openssl speed -engine $engine_id -async_jobs 1 -evp sha1
	openssl speed -engine $engine_id -evp sha224
	openssl speed -engine $engine_id -async_jobs 1 -evp sha224
	openssl speed -engine $engine_id -evp sha256
	openssl speed -engine $engine_id -async_jobs 1 -evp sha256
	openssl speed -engine $engine_id -evp sha384
	openssl speed -engine $engine_id -async_jobs 1 -evp sha384
	openssl speed -engine $engine_id -evp sha512
	openssl speed -engine $engine_id -async_jobs 1 -evp sha512
fi

#cipher

if [[ $algs =~ "AES" ]]; then
	echo "testing AES"
	openssl speed -engine $engine_id -evp aes-128-cbc
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-128-cbc
	openssl speed -engine $engine_id -evp aes-192-cbc
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-192-cbc
	openssl speed -engine $engine_id -evp aes-256-cbc
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-256-cbc
	openssl speed -engine $engine_id -evp aes-128-ecb
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-128-ecb
	openssl speed -engine $engine_id -evp aes-192-ecb
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-192-ecb
	openssl speed -engine $engine_id -evp aes-256-ecb
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-256-ecb
	openssl speed -engine $engine_id -evp aes-128-xts
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-128-xts
	openssl speed -engine $engine_id -evp aes-256-xts
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-256-xts
	openssl speed -engine $engine_id -evp aes-128-ctr
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-128-ctr
	openssl speed -engine $engine_id -evp aes-192-ctr
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-192-ctr
	openssl speed -engine $engine_id -evp aes-256-ctr
	openssl speed -engine $engine_id -async_jobs 1 -evp aes-256-ctr
fi

if [[ $algs =~ "SM4-CBC" ]]; then
	echo "testing SM4-CBC"
	openssl speed -engine $engine_id -evp sm4-cbc
	openssl speed -engine $engine_id -async_jobs 1 -evp sm4-cbc
fi

if [[ $algs =~ "SM4-ECB" ]]; then
	echo "testing SM4-ECB"
	openssl speed -engine $engine_id -evp sm4-ecb
	openssl speed -engine $engine_id -async_jobs 1 -evp sm4-ecb
fi

if [[ $algs =~ "DES" ]]; then
	echo "testing DES"
	openssl speed -engine $engine_id -evp des-ede3-cbc
	openssl speed -engine $engine_id -async_jobs 1 -evp des-ede3-cbc
	openssl speed -engine $engine_id -evp des-ede3-ecb
	openssl speed -engine $engine_id -async_jobs 1 -evp des-ede3-ecb
fi

#rsa
if [[ $algs =~ "RSA" ]]; then
	echo "testing RSA"
	openssl speed -elapsed -engine $engine_id rsa1024
	openssl speed -elapsed -engine $engine_id -async_jobs 1 rsa1024
	openssl speed -elapsed -engine $engine_id rsa2048
	openssl speed -elapsed -engine $engine_id -async_jobs 1 rsa2048
	openssl speed -elapsed -engine $engine_id rsa4096
	openssl speed -elapsed -engine $engine_id -async_jobs 1 rsa4096
fi

#ecdsa only supported in HW_V3 or later
if [[ $algs =~ "id-ecPublicKey" ]]; then
	echo "testing ECDSA"
	openssl speed -elapsed -engine $engine_id ecdsap224
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdsap224
	openssl speed -elapsed -engine $engine_id ecdsap256
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdsap256
	openssl speed -elapsed -engine $engine_id ecdsap384
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdsap384
	openssl speed -elapsed -engine $engine_id ecdsap521
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdsap521
fi

#X25519 only supported in HW_V3 or later
if [[ $algs =~ "X25519" ]]; then
	echo "testing X25519"
	openssl speed -elapsed -engine $engine_id ecdhx25519
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhx25519
fi

#X448 only supported in HW_V3 or later
if [[ $algs =~ "X448" ]]; then
	echo "testing X448"
	openssl speed -elapsed -engine $engine_id ecdhx448
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhx448
fi

#ecdh only supported in HW_V3 or later
if [[ $algs =~ "id-ecPublicKey" ]]; then
	echo "testing ECDH"
	openssl speed -elapsed -engine $engine_id ecdhp192
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhp192
	openssl speed -elapsed -engine $engine_id ecdhp224
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhp224
	openssl speed -elapsed -engine $engine_id ecdhp256
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhp256
	openssl speed -elapsed -engine $engine_id ecdhp384
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhp384
	openssl speed -elapsed -engine $engine_id ecdhp521
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhp521
	openssl speed -elapsed -engine $engine_id ecdhbrp384r1
	openssl speed -elapsed -engine $engine_id -async_jobs 1 ecdhbrp384r1
fi

#DH
if [[ $algs =~ "DH" ]]; then
	echo "testing DH"
	#1. Generate global public parameters, and save them in the file dhparam.pem:
	openssl dhparam -out dhparam.pem 2048

	#2. Generate own private key:
	openssl genpkey -paramfile dhparam.pem -out privatekey1.pem
	openssl genpkey -paramfile dhparam.pem -out privatekey2.pem

	#3. Generate public key:
	openssl pkey -in privatekey1.pem -pubout -out publickey1.pem -engine $engine_id
	openssl pkey -in privatekey2.pem -pubout -out publickey2.pem -engine $engine_id

	#4. After exchanging public key, each user can derive the shared secret:
	openssl pkeyutl -derive -inkey privatekey1.pem -peerkey publickey2.pem -out secret1.bin -engine $engine_id
	openssl pkeyutl -derive -inkey privatekey2.pem -peerkey publickey1.pem -out secret2.bin -engine $engine_id

	#5. Check secret1.bin and secret2.bin:
	cmp secret1.bin secret2.bin
	xxd secret1.bin
	xxd secret2.bin
	#secret1.bin and secret2.bin should be same.
fi
