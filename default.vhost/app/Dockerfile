### STAGE 1: Build ###

# We label our stage as ‘builder’
FROM node:14.4.0-alpine3.12 as builder

WORKDIR /app

COPY package*.json ./

RUN npm install
# RUN cp -a /node_modules /app

COPY . .
ENV VIRTUAL_PORT=8080
EXPOSE 8080
ENV LETSENCRYPT_HOST=grimes.org
ENV LETSENCRYPT_EMAIL=andi@radikrahl.com

CMD [ "node", "server.js" ]
