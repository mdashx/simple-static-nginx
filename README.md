# Simple Static Nginx

Simple setup for static sites on Nginx with SSL certs from
LetsEncrypt. Quickly host multiple sites on a single server. Launch a
new site with one command.

This isn't the most efficient or clever way of doing things, but it is
pretty straightforward.

Set environment variables like this:

```
export USER=tom
export HOST=hydrogen
export WORKING_DIR=dhammacharts
export EMAIL=tom@mdashx.com
export HOST_DOMAIN=www.dhammacharts.com
```

Then run `make site-entire`.

Then change the HOST_DOMAIN and add a redirect target:

```
export USER=tom
export HOST=hydrogen
export WORKING_DIR=dhammacharts
export EMAIL=tom@mdashx.com
export HOST_DOMAIN=dhammacharts.com
export TARGET=www.dhammacharts.com
```

Then run `make redirect-entire`.

Check out the Makefile.
