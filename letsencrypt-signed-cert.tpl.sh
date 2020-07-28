#!/bin/bash

mkdir -p /var/www/certbot


rm -Rf /etc/letsencrypt/live/{{ HOST_DOMAIN }}
rm -Rf /etc/letsencrypt/archive/{{ HOST_DOMAIN }}
rm -Rf /etc/letsencrypt/renewal/{{ HOST_DOMAIN }}.conf

certbot certonly --webroot -w /var/www/certbot \
    --cert-name {{ HOST_DOMAIN }} \
    -d {{ HOST_DOMAIN }} \
    --email {{ EMAIL }} \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal
