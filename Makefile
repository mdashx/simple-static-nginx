################
# Install Docker
################

# You should probably install Docker following instructions for your
# distro, but if you happen to be on Ubuntu, this command might work for
# you.

.PHONY:
docker:
	ssh -t root@${HOST} 'apt update'
	ssh -t root@${HOST} 'apt upgrade'
	ssh -t root@${HOST} 'apt install docker.io'
	ssh root@${HOST} 'systemctl unmask docker && systemctl enable --now docker'
	ssh root@${HOST} 'usermod -aG docker ${USER}'


#########################
# Docker/Nginx Management
#########################

.PHONY: compose
compose:
	cp docker-compose.tpl.yml docker-compose.yml
	sed -i 's/{{ CONTAINER_NAME }}/${CONTAINER_NAME}/' docker-compose.yml

.PHONY: start
start:
	ssh ${USER}@${HOST} 'cd /home/${USER}/${WORKING_DIR} && docker-compose up -d'

.PHONY: stop
stop:
	ssh ${USER}@${HOST} 'docker kill ${CONTAINER_NAME}'

.PHONY: restart
restart: stop start


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


.PHONY: copy
copy:
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/conf.d/'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/html/'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/certbot/conf'
	ssh ${USER}@${HOST} 'mkdir -p /home/${USER}/${WORKING_DIR}/certbot/www'

	scp conf.d/${HOST_DOMAIN}.conf \
		${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/conf.d/${HOST_DOMAIN}.conf

	rsync -avzh --delete html/${HOST_DOMAIN} \
		${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/html

	scp nginx.conf ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/nginx.conf
	scp docker-compose.yml ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}/docker-compose.yml


##################
# Install SSL Cert
##################

.PHONY: cert
cert:
	cp letsencrypt.tpl.sh letsencrypt.sh
	sed -i 's/{{ HOST_DOMAIN }}/${HOST_DOMAIN}/' letsencrypt.sh
	sed -i 's/{{ EMAIL }}/${EMAIL}/' letsencrypt.sh
	scp letsencrypt.sh ${USER}@${HOST}:/home/${USER}/${WORKING_DIR}
	ssh ${USER}@${HOST} -t 'cd /home/${USER}/${WORKING_DIR} && bash letsencrypt.sh'
	rm letsencrypt.sh


#####################################################
# Do the whole process (assuming Docker is installed)
#####################################################

.PHONY: site-entire
site-entire: compose site copy start cert

.PHONY: redirect-entire
redirect-entire: compose redirect copy start cert
