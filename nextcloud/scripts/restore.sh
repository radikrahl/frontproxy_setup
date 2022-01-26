#!/bin/bash
set -x

### Main config ###
backupMainDir="/bkp/nextcloud"
date=$1

### fileNames ###
fileNameConfig="config_${date}.tar.gz"
fileNameData="data_${date}.tar.gz"
fileNameThemes="themes_${date}.tar.gz"
fileNameCustomApps="custom_${date}.tar.gz"
fileNameBackup="nextcloud-sqlbkp_${date}.bak"
sqlDump="${backupMainDir}/${date}/${fileNameBackup}"

tempFolder="_temp/nextcloud"

## nextcloud ##
dbUser="nextcloud"
dbPassword="9Dr1w0vnfutqbZ0T5gCKhGCljoYeDtnJ"
webserverUser="www-data"
dockerapp="nextcloud"

## sql ##
dockerdb="nextcloud_db_1"

## Check for root ##
if [ "$(id -u)" != "0" ]; then
    errorecho "ERROR: This script has to be run as root!"
    exit 1
fi

if [ -z "$date" ]; then
    errorecho "ERROR: Please specify date folder for backup"
    exit 1
elif [ ! -d $1 ]; then
    errorecho "ERROR: given folder does not exist"
    exit 1
fi

### Ensure directories exist ###
ensureCreated() {
    if [ ! -d $1 ]; then
        mkdir -p $1
    else
        errorecho "WARN: directory exists"
    fi
}

ensureCreated ${backupMainDir}
ensureCreated "${tempFolder}/config"
ensureCreated "${tempFolder}/data"
ensureCreated "${tempFolder}/themes"
ensureCreated "${tempFolder}/customApps"

### Prepare temp folder to copy ###
tar -xpzf "${backupMainDir}/${date}/backup/${fileNameConfig}" -C "${tempFolder}/config/"
tar -xpzf "${backupMainDir}/${date}/backup/${fileNameData}" -C "${tempFolder}/data/"
tar -xpzf "${backupMainDir}/${date}/backup/${fileNameThemes}" -C "${tempFolder}/themes/"
tar -xpzf "${backupMainDir}/${date}/backup/${fileNameCustomApps}" -C "${tempFolder}/customApps/"

### Set maintenance mode ###
echo "Wartungsmodus fuer Nextcloud wird aktiviert"
docker exec -u ${webserverUser} ${dockerapp} php occ maintenance:mode --on
echo "Status: OK"

### Restore database ###
docker cp $sqlDump "${dockerdb}:/dmp"
docker exec ${dockerdb} /bin/bash -c "/usr/bin/mysql -u ${dbUser} -p${dbPassword} nextcloud < /dmp"
docker exec ${dockerdb} /bin/bash -c "rm -r -f /dmp"

### Restore Files ###
docker exec ${dockerapp} rm -r -f "/nextcloud_bkp"
docker exec ${dockerapp} mkdir "/nextcloud_bkp"
docker cp ${tempFolder} ${dockerapp}:"/nextcloud_bkp"
docker exec ${dockerapp} rsync -Aax /nextcloud_bkp /var/www/html

### Disable maintenance mode ###
docker exec ${dockerapp} su -s /bin/bash ${webserverUser} -c "php occ maintenance:mode --off"
docker exec ${dockerapp} su -s /bin/bash ${webserverUser} -c "php occ maintenance:data-fingerprint"