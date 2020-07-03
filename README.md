# Simple Static Nginx

Simple setup for static sites on Nginx with SSL certs from
LetsEncrypt. Quickly host multiple sites on a single server. Launch a
new site with one command.

This isn't the most efficient or clever way of doing things, but it is
pretty straightforward.

---

## The whole thing in one command

_(Assuming Docker is already installed on the remote machine)._

To setup a site: `HOST_DOMAIN=www.dhammacharts.com make site-entire`

And to create a redirect: `HOST_DOMAIN=dhammacharts.com
TARGET=www.dhammacharts.com make redirect-entire`


## Step-by-step

I'm going through the process of setting up the site
www.dhammacharts.com and documenting everything here as I go. If you
want to use this project to setup your own sites, just follow along
with these steps.

### DNS

I'm going to host the site on www.dhammacharts.com and redirect the
naked url "dhammacharts.com" to the WWW subdomain. Both the naked
domain (the "@" host) and the WWW domain have A records pointing to
the IP address for the server.

### Environment Variables

_You can start by just copying and editing the sample `.env` file._

`USER`: regular user on the server where the Nginx container will
run.

`HOST`: Hostname (from .ssh/config, etc.), domain name, or IP address
of server

`WORKING_DIR`: - Directory inside the user's home dir where the config
files will live. For example, I use the path `webserver`, so the
`docker-compose.yml` and other files will all live in
`/home/tom/webserver`.

`CONTAINER_NAME`: Name the container so it is simple to kill by name.

`HOST_DOMAIN`: The host to configure. Set this in the command, not in
the `.env` file.

`TARGET` - When generating an Nginx config to redirect one host to
another, the `$HOST_DOMAIN` is redirected to the `$TARGET`.

`EMAIL` - The email address to use for LetsEncrypt.

### Create Docker Compose config

`make compose` will create a Docker Compose config using the container
name for Nginx that you specify in the `CONTAINER_NAME` env var.

### Create Nginx configs and initial content

#### Create site

The command: `HOST_DOMAIN=www.dhammacharts.com make site` creates an
Nginx config for hosting content at the WWW subdomain, and creates a
placeholder `index.html` file in the directory
`html/www.dhammacharts.com`.

#### Create redirect

The command: `HOST_DOMAIN=dhammacharts.com TARGET=www.dhammacharts.com
make redirect` creates an Nginx config file to redirect the naked
domain to the WWW subdomain, and creates the placeholder HTML content.

### Deploy the site

First copy the site config to the server:
`HOST_DOMAIN=www.dhammacharts.com make copy`, then copy the redirect
config, `HOST_DOMAIN=dhammacharts.com make copy`, and restart Nginx:
`make restart`.

### Install SSL certificates from LetsEncrypt

We'll get a cert for both of the hosts we're working with.

`HOST_DOMAIN=www.dhammacharts.com make cert`
`HOST_DOMAIN=dhammacharts.com make cert`

