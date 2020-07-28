#!/bin/bash

# Make sure we have a directory to work in
mkdir -p /etc/letsencrypt/

# Use recommended SSL options from Let's Encrypt
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > /etc/letsencrypt/options-ssl-nginx.conf

curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > /etc/letsencrypt/ssl-dhparams.pem

# Create a path for our site's keys
path="/etc/letsencrypt/live/{{ HOST_DOMAIN }}"
mkdir -p $path

# Create self-signed certficiate
openssl req -x509 -nodes -newkey rsa:2048 -days 1\
    -keyout "$path/privkey.pem" \
    -out "$path/fullchain.pem" \
    -subj '/CN=localhost'
