#!/bin/bash
set -x

docker exec -u www-data nextcloud php occ --no-warnings config:system:set allow_local_remote_servers --value=true

docker exec -u www-data nextcloud php occ --no-warnings app:install onlyoffice

docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="<your-office-url-here>"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nextcloud/"