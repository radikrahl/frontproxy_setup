# assuming we are in frontproxy_setup/scripts folder
cd ..

cd traefik && \ 
    docker-compose -f docker-compose.production.yml pull && \ 
    docker-compose -f docker-compose.production.yml up -d && \
    cd ..

cd ghost && \
    docker-compose -f docker-compose.production.yml pull && \
    docker-compose -f docker-compose.production.yml up -d && \
    cd ..

cd nextcloud && \
    docker-compose pull && docker-compose up -d && \
    cd ..

cd wp_africaknow && \
    docker-compose pull && docker-compose up -d && \
    cd ..