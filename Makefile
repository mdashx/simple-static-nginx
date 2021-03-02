###############
# Install Nginx
###############

.PHONY: nginx
nginx:
	ssh ${USER}@${HOST} 'sudo apt-get update'
	ssh ${USER}@${HOST} 'sudo apt-get install -y nginx'
	ssh ${USER}@${HOST} 'sudo systemctl start nginx'
	ssh ${USER}@${HOST} 'sudo systemctl status nginx'

.PHONY: nginx-conf
nginx-conf:
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}'
	scp nginx.conf ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/nginx.conf
	ssh ${USER}@${HOST} 'sudo cp ${WORKING_DIR}/nginx.conf /etc/nginx/nginx.conf'

.PHONY: nginx-restart
nginx-restart:
	ssh ${USER}@${HOST} 'sudo systemctl restart nginx'
	ssh ${USER}@${HOST} 'sudo systemctl status nginx'


############################
# Create/deploy site content
############################

.PHONY: content
content:
	mkdir -p html/${HOST_DOMAIN}
	echo "Hello world! I am ${HOST_DOMAIN}" > html/${HOST_DOMAIN}/index.html
	cp favicon.ico html/${HOST_DOMAIN}/favicon.ico

.PHONY: site
site: content
	mkdir -p conf.d
	cp site.tpl.conf conf.d/${HOST_DOMAIN}.conf
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' conf.d/${HOST_DOMAIN}.conf


.PHONY: redirect 
redirect: content
	mkdir -p conf.d
	cp redirect.tpl.conf conf.d/${HOST_DOMAIN}.conf
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' conf.d/${HOST_DOMAIN}.conf
	sed -i 's/{{ TARGET }}/${TARGET}/' conf.d/${HOST_DOMAIN}.conf


# Install our site config on server with self-signed SSL cert
.PHONY: site-install
site-install:
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/conf.d/'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/html/'

	scp conf.d/${HOST_DOMAIN}.conf \
		${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/conf.d/${HOST_DOMAIN}.conf
	ssh ${USER}@${HOST} 'sudo cp ${WORKING_DIR}/conf.d/${HOST_DOMAIN}.conf /etc/nginx/conf.d/${HOST_DOMAIN}.conf'

	rsync -avzh --delete html/${HOST_DOMAIN} \
		${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/html

	ssh ${USER}@${HOST} 'sudo rsync --recursive --delete ${WORKING_DIR}/html/${HOST_DOMAIN} /usr/share/nginx/html'

	cp self-signed-cert.tpl.sh self-signed-cert.sh
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' self-signed-cert.sh
	scp self-signed-cert.sh ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}
	ssh ${USER}@${HOST} -t 'cd /home/${USER}/${WORKING_DIR} && sudo bash self-signed-cert.sh'

	ssh ${USER}@${HOST} 'sudo systemctl restart nginx'
	ssh ${USER}@${HOST} 'sudo systemctl status nginx'


##################
# Install SSL Cert
##################

.PHONY: cert
cert:
	ssh ${USER}@${HOST}	'sudo apt-get update'
	ssh ${USER}@${HOST}	'sudo apt-get install software-properties-common'
	ssh ${USER}@${HOST}	'sudo add-apt-repository universe'
	ssh ${USER}@${HOST}	'sudo apt-get update'
	ssh ${USER}@${HOST}	'sudo apt-get install certbot python3-certbot-nginx'

	cp letsencrypt-signed-cert.tpl.sh letsencrypt-signed-cert.sh
	sed -i 's/{{ EMAIL }}/${EMAIL}/' letsencrypt-signed-cert.sh
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' letsencrypt-signed-cert.sh
	scp letsencrypt-signed-cert.sh ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}
	ssh ${USER}@${HOST} -t 'cd /home/${USER}/${WORKING_DIR} && sudo bash letsencrypt-signed-cert.sh'



########################################################
# Do the whole process (assuming Nginx is already setup)
########################################################

.PHONY: site-entire
site-entire: content site site-install cert nginx-restart

.PHONY: redirect-entire
redirect-entire: content redirect site-install cert nginx-restart


################
# Renew SSL Cert
################
.PHONY: renew-cert
renew-cert:
	cp letsencrypt-renew.tpl.sh letsencrypt-renew.sh
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' letsencrypt-renew.sh
	scp letsencrypt-renew.sh ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}
	ssh ${USER}@${HOST} -t 'cd /home/${USER}/${WORKING_DIR} && sudo bash letsencrypt-renew.sh'

