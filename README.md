# frontproxy_setup
setup with [traefik.io](https://traefik.io)

# Setup
Create `.env` File with the approptiate variables given in the respective docker-compose file.

```
docker-compose -f traefik/docker-compose.production.yml up -d
docker-compose -f wordpress/docker-compose.yml up -d
```
