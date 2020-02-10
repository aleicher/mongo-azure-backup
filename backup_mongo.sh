#!/bin/bash

set -e

# define the following in your env
# MONGO_URI => mongo host URI
# MONGO_USERNAME => username for mongodb
# MONGO_PASSWORD => password to authenticate against mongodb
# MONGO_AUTH_DB => name of mongo authentication database
# AZURE_SA => Azure Storage account name
# AZURE_BLOB_CONTAINER => name of the azure storage blob container
# AZURE_SHARE_NAME => name of the azure file share
# AZURE_DESTINATION_KEY => azure storage account destination key
# DB => mongo db to backup
# USE_MONGO_URI_PREFIX => when set include the Mongo URI in the backup filename

# check the mongo uri
if [ -z "$MONGO_URI" ]; then
  echo "Error: you must set the MONGO_URI environment variable"
  exit 1
fi

# check the mongo db
if [ -z "$DB" ]; then
  echo "Error: you must set the DB environment variable"
  exit 2
fi

# check the azure args
if [ -z "$AZURE_SA" ] || [ -z "$AZURE_DESTINATION_KEY" ]; then
  echo "Error: you must set all Azure storage account variables AZURE_SA and AZURE_DESTINATION_KEY"
  exit 3
fi

# get the azure destination type and name
if [ ! -z "${AZURE_BLOB_CONTAINER}" ]; then
  AZURE_TYPE=blob
  AZURE_CONTAINER_NAME=${AZURE_BLOB_CONTAINER}
elif [ ! -z "${AZURE_SHARE_NAME}" ]; then
  AZURE_TYPE=file
  AZURE_CONTAINER_NAME=${AZURE_SHARE_NAME}
else
  echo "Error: you must set either AZURE_BLOB_CONTAINER or AZURE_SHARE_NAME"
  exit 4
fi

# check the mongo auth params
if [ -z "$MONGO_USERNAME" ] && [ -z "$MONGO_PASSWORD" ] && [ -z "$MONGO_AUTH_DB" ]; then
  NO_AUTH=${NO_AUTH:-true}
elif [ -z "$MONGO_USERNAME" ] || [ -z "$MONGO_PASSWORD" ] || [ -z "$MONGO_AUTH_DB" ]; then
  echo "Error: you must set all the MongoDB authentication environment variables MONGO_USERNAME, MONGO_PASSWORD and MONGO_AUTH_DB"
  exit 5
fi

DB_ARG="--db ${DB}"
if [ "${DB}" = "." ] || [ "${DB}" = "*" ] || [ "${DB}" = "all" ]; then
  DB=all
  DB_ARG=
fi

DIRECTORY=$(date +%Y-%m-%d)

BACKUP_NAME="${DB}-$(date +%Y%m%d_%H%M%S).gz"

# if prefix is enabled include the mongo uri in the backup name
if [ ! -z "${USE_MONGO_URI_PREFIX}" ]; then
  BACKUP_NAME_PREFIX="${MONGO_URI//[:]/-}-"
fi

LOCAL_PATH="$HOME/tmp_dump.gz"
REMOTE_PATH="https://${AZURE_SA}.${AZURE_TYPE}.core.windows.net/${AZURE_CONTAINER_NAME}/${DIRECTORY}/${BACKUP_NAME_PREFIX}${BACKUP_NAME}"
REMOTE_LATEST_PATH="https://${AZURE_SA}.${AZURE_TYPE}.core.windows.net/${AZURE_CONTAINER_NAME}/latest/${BACKUP_NAME_PREFIX}${DB}-backup.gz"

date
echo "Backing up MongoDB database(s) ${DB}"

echo "Dumping MongoDB $DB database(s) to compressed archive"
if [ "$NO_AUTH" = true ]
then
  mongodump --host "${MONGO_URI}" ${DB_ARG} --archive="${LOCAL_PATH}" --gzip
else
  mongodump --authenticationDatabase "${MONGO_AUTH_DB}" -u "${MONGO_USERNAME}" -p "${MONGO_PASSWORD}" --host "${MONGO_URI}" ${DB_ARG} --archive="${LOCAL_PATH}" --gzip
fi

echo "Copying compressed archive to Azure Storage: ${AZURE_SA}.${AZURE_TYPE}/${AZURE_CONTAINER_NAME}/${DIRECTORY}/${BACKUP_NAME_PREFIX}${BACKUP_NAME}"
azcopy --source "${LOCAL_PATH}" --destination "${REMOTE_PATH}" --dest-key "${AZURE_DESTINATION_KEY}"
yes | azcopy --source "${REMOTE_PATH}" --destination "${REMOTE_LATEST_PATH}" --source-key "${AZURE_DESTINATION_KEY}" --dest-key "${AZURE_DESTINATION_KEY}"

echo "Cleaning up compressed archive"
rm "${LOCAL_PATH}"

echo 'Backup complete!'
