## Cronjob
### Enable cronjob
`sudo crontab -e`
`* 2 * * * 'path to scriptfile' >> 'path to logfile'`

### Give script permissions
`sudo chmod +x 'path to scriptfile'`

## Restore
Call restore.sh with folder name as parameter