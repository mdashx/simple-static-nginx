#!/bin/bash

certbot certonly --webroot -w /var/www/certbot -d {{ HOST_DOMAIN }}
