#!/bin/bash
# set -x
### Main config ###
$currentDate=$(Get-Date -UFormat "%Y%m%d_%R") | ForEach-Object { $_ -replace ":", "" }
$fileNameConfig="config_${currentDate}.tar.gz"
$fileNameData="data_${currentDate}.tar.gz"
$fileNameThemes="themes_${currentDate}.tar.gz"
$fileNameCustomApps="custom_${currentDate}.tar.gz"
### Params ###
#loescht Backups, die aelter als 14 Tage sind
$backupalter="14"
# Verzeichnis, wo eure Daten gesichert werden sollen
$backupMainDir="c:/_temp/sicherung/"
$backupdir="${backupMainDir}/${currentDate}/"
# Verzeichnis, in dem eure Nextcloud Installation liegt
$nextcloudFileDir="c:/_temp/containers/nextcloud/app"
# Verzeichnis, in dem eure Nextcloud User Daten liegen
$nextcloudDataDir="c:/_temp/containers/nextcloud"
# Name eurer Nextcloud Datenbank
$nextcloudDatabase="nextcloud"
# Name eures Nextcloud Datenbank Users
$dbUser="nextcloud"
# Passwort eures Nextcloud Datenbank Users
$dbPassword="9Dr1w0vnfutqbZ0T5gCKhGCljoYeDtnJ"
$webserverUser="www-data"
# Name eures Nextcloud DB Containers
$dockerdb="nextcloud_db_1"
#Name eures Nextcloud App Containers
$dockerapp="nextcloud"
# Paths
$SRC_PATH="/var/www/html"
$DEST_PATH="${backupdir}/"
### Check if backup dir already exists ###
if ( Test-Path -Path "${backupdir}" )
{
    Write-Output "ERROR: The backup directory ${backupdir} already exists!"
    exit 1
}
else
{
    mkdir -p "${backupdir}"
}

### Set maintenance mode ###
Write-Output "Wartungsmodus fuer Nextcloud wird aktiviert"
docker exec -u ${webserverUser} ${dockerapp} php occ maintenance:mode --on
Write-Output "Status: OK"
### Copy and tar files from container to host ###
docker exec ${dockerapp} mkdir "/backup"
docker exec ${dockerapp} tar -czvf "/backup/${fileNameConfig}" "${SRC_PATH}/config"
docker exec ${dockerapp} tar -czvf "/backup/${fileNameData}" "${SRC_PATH}/data"
docker exec ${dockerapp} tar -czvf "/backup/${fileNameThemes}" "${SRC_PATH}/themes"
docker exec ${dockerapp} tar -czvf "/backup/${fileNameCustomApps}" "${SRC_PATH}/custom_apps"
docker cp "${dockerapp}:/backup/" ${DEST_PATH}
docker exec ${dockerapp} rm -r -f "/backup"
### Create SQL dumpfile ###
docker exec ${dockerdb} mysqldump --single-transaction -h "db" -u ${dbUser} --password=${dbPassword} "nextcloud" > "${DEST_PATH}/nextcloud-sqlbkp_${currentDate}.bak"
### Disable maintenance mode ###
Write-Output "Deaktivierung des Wartungsmodus"
docker exec -u ${webserverUser} ${dockerapp} php occ maintenance:mode --off
Write-Output "Status: OK"