$date="20210419_1820"
$fileNameConfig="config_${date}.tar.gz"
$fileNameData="data_${date}.tar.gz"
$fileNameThemes="themes_${date}.tar.gz"
$fileNameCustomApps="custom_${date}.tar.gz"

$dockerdb="nextcloud_db_1"
$fileNameBackup="nextcloud-sqlbkp_${date}.bak"
$sqlDump="c:/_temp/sicherung/$date/${fileNameBackup}"

$tempFolder="c:/_temp/containers/nextcloud"

$dbUser="nextcloud"
$dbPassword="9Dr1w0vnfutqbZ0T5gCKhGCljoYeDtnJ"
#Installationsdateien
tar -xpzf "c:/_temp/sicherung/$date/backup/${fileNameConfig}" -C "$tempFolder/config/"
tar -xpzf "c:/_temp/sicherung/$date/backup/${fileNameData}" -C "$tempFolder/data/"
tar -xpzf "c:/_temp/sicherung/$date/backup/${fileNameThemes}" -C "$tempFolder/themes/"
tar -xpzf "c:/_temp/sicherung/$date/backup/${fileNameCustomApps}" -C "$tempFolder/customApps/"

### Set maintenance mode ###
Write-Output "Wartungsmodus fuer Nextcloud wird aktiviert"
$webserverUser="www-data"
$dockerapp="nextcloud"
docker exec -u ${webserverUser} ${dockerapp} php occ maintenance:mode --on
Write-Output "Status: OK"

### Restore database ###
docker cp $sqlDump "${dockerdb}:/dmp"
docker exec ${dockerdb} /bin/bash -c "/usr/bin/mysql -u ${dbUser} -p${dbPassword} nextcloud < /dmp"
docker exec ${dockerdb} /bin/bash -c "rm -r -f /dmp"

### Restore Files ###
docker exec $dockerapp rm -r -f "/nextcloud_bkp"
docker exec $dockerapp mkdir "/nextcloud_bkp"
docker cp $tempFolder ${dockerapp}:"/nextcloud_bkp"
docker exec $dockerapp rsync -Aax /nextcloud_bkp /var/www/html

docker exec $dockerapp su -s /bin/bash $webserverUser -c "php occ maintenance:mode --off"
docker exec $dockerapp su -s /bin/bash $webserverUser -c "php occ maintenance:data-fingerprint"