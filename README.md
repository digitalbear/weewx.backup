# WeeWX Backup

This repo contains the bash scripts that I use to backup my WeeWX weather station database and archive to AWS S3.

See [http://www.weewx.com/](http://www.weewx.com/) for more info about the weather station software.

The backup script will first stop the weewx service, dump the sqlite3 database, start the weewx service up again and call the s3 archive script.

The s3 archive script will:  
1. **Every day**: push a copy of the backup file to the "daily" directory and remove entries more than a week old  
2. **Every Sunday**: push a copy of the backup file to the "weekly" directory and remove entries more than a month old  
3. **On the 1st of every month**: push a copy of the backup file to the "monthly" directory and remove entries more than a year old  
4. **On the 1st of January every year**: push a copy of the backup file to the "annual" directory.  No entries will be removed from the annual directory  

The s3 archive script uses [s3cmd](https://github.com/s3tools/s3cmd) - a really useful command-line tool for interacting with Amazon S3.
