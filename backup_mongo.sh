#!/bin/bash

set -e

# define the following in your env
# MONGO_URI => mongo host URI
# MONGO_USERNAME => username for mongodb
# MONGO_PASSWORD => password to authenticate against mongodb
# MONGO_AUTH_DB => name of mongo authentication database
# AZURE_SA => Azure Storage account name
# AZURE_BLOB_CONTAINER => name of the azure storage blob container
# AZURE_DESTINATION_KEY => azure storage account destination key
# DB => mongo db to backup


DIRECTORY=$(date +%Y-%m-%d)

BACKUP_NAME=${DB}-$(date +%Y%m%d_%H%M%S).gz

date
echo "Backing up MongoDB database ${DB}"

echo "Dumping MongoDB $DB database to compressed archive"
if [ "$NO_AUTH" = true ]
then
  mongodump --host ${MONGO_URI} --db ${DB} --archive=$HOME/tmp_dump.gz --gzip
else
  mongodump --authenticationDatabase ${MONGO_AUTH_DB} -u ${MONGO_USERNAME} -p ${MONGO_PASSWORD} --host ${MONGO_URI} --db ${DB} --archive=$HOME/tmp_dump.gz --gzip
fi

echo "Copying compressed archive to Azure Storage: ${AZURE_SA}/${AZURE_BLOB_CONTAINER}/${DIRECTORY}/${BACKUP_NAME}"
azcopy --source $HOME/tmp_dump.gz --destination https://${AZURE_SA}.blob.core.windows.net/${AZURE_BLOB_CONTAINER}/${DIRECTORY}/${BACKUP_NAME} --dest-key ${AZURE_DESTINATION_KEY}
yes | azcopy --source $HOME/tmp_dump.gz --destination https://${AZURE_SA}.blob.core.windows.net/${AZURE_BLOB_CONTAINER}/latest/backup.gz --dest-key ${AZURE_DESTINATION_KEY}

echo "Cleaning up compressed archive"
rm $HOME/tmp_dump.gz

echo 'Backup complete!'
