#!/bin/sh

# Simple one-liner to encrypt a hexadecimal string using AES-128 from the terminal. 
# Usage: ./aes-encrypt.sh <hex_plaintext> <hex_key>
# Example: ./aes-encrypt.sh 00112233445566778899aabbccddeeff 000102030405060708090a0b0c0d0e0f
# Very useful for debugging and testing purposes.
echo -n $1 | xxd -r -p | openssl enc -aes-128-ecb -K $2 -nosalt -nopad | xxd -p