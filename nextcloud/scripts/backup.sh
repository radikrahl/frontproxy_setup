#!/bin/bash
set -x

### Main config ###
currentDate=$(date +"%Y%m%d%H%M%S")
backupAge="14"
echoDate=$(date +"%m/%d/%Y %H:%M")

## File Names ##
fileNameConfig="config_${currentDate}.tar.gz"
fileNameData="data_${currentDate}.tar.gz"
fileNameThemes="themes_${currentDate}.tar.gz"
fileNameCustomApps="custom_${currentDate}.tar.gz"
### Params ###
backupMainDir="/bkp/nextcloud"
backupdir="${backupMainDir}/${currentDate}/"

## nextcloud ##
nextcloudDatabase="nextcloud"
dbUser="nextcloud"
dbPassword="9Dr1w0vnfutqbZ0T5gCKhGCljoYeDtnJ"
nextcloudServerUser="www-data"

## docker ##
dockerdb="nextcloud_db_1"
dockerapp="nextcloud"
dockerdbHost="db"
## Paths ##
SRC_PATH="/var/www/html"
DEST_PATH="${backupdir}/"

## Check for root ##
if [ "$(id -u)" != "0" ]; then
    errorecho "${echoDate}: ERROR: This script has to be run as root!"
    exit 1
fi

### Check if backup dir already exists ###
if [ ! -d "${backupdir}" ]; then
    mkdir -p "${backupdir}"
else
    errorecho "${echoDate}: ERROR: The backup directory ${backupdir} already exists!"
    exit 1
fi

### Set maintenance mode ###
echo "${echoDate}: Enabling maintenance mode"
docker exec -u ${nextcloudServerUser} ${dockerapp} php occ maintenance:mode --on
echo "${echoDate}: Status: OK"

### Copy and tar files from container to host ###
docker exec ${dockerapp} mkdir "/backup"
docker exec ${dockerapp} tar -czf "/backup/${fileNameConfig}" "${SRC_PATH}/config"
docker exec ${dockerapp} tar -czf "/backup/${fileNameData}" "${SRC_PATH}/data"
docker exec ${dockerapp} tar -czf "/backup/${fileNameThemes}" "${SRC_PATH}/themes"
docker exec ${dockerapp} tar -czf "/backup/${fileNameCustomApps}" "${SRC_PATH}/custom_apps"
docker cp "${dockerapp}:/backup/" ${DEST_PATH}
docker exec ${dockerapp} rm -r -f "/backup"
echo "${echoDate}: Successfully created tar files"

### Create SQL dumpfile ###
docker exec ${dockerdb} mysqldump --single-transaction -h ${dockerdbHost} -u ${dbUser} --password=${dbPassword} ${nextcloudDatabase} >"${DEST_PATH}/nextcloud-sqlbkp_${currentDate}.bak"

### Delete old files ###
cleanup() {
    del=$(date --date="${backupAge} days ago" +%Y%m%d%H%M%S)
    path="${backupMainDir}"
    for i in `find ${backupMainDir} -type d -name "2*"`; do
        (($del > $(basename $i))) && (rm -rf $i && echo "${echoDate}: Deleted ${i}") || echo "${echoDate}: No delete"
    done
}

echo "${echoDate}: Delete files that exist longer than" "${backupAge}" "days."
cleanup
echo "${echoDate}: Delete empty folder"
find "${backupMainDir}" -type d -empty -delete


echo "${echoDate}: Disable maintenance mode"
docker exec -u ${nextcloudServerUser} ${dockerapp} php occ maintenance:mode --off
echo "${echoDate}: Status: OK"
