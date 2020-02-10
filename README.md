# backup mongodb in azure storage

A little helper to create a backup of a mongodb using `mongodump`, storing the dump in azure blob or file storage using `azcopy`.

Tools used:

 - [azcopy](https://docs.microsoft.com/de-de/azure/storage/common/storage-use-azcopy-linux)
 - [mongodump](https://docs.mongodb.com/manual/reference/program/mongodump/)


# setup & usage

## compose

Make sure you set the following environment variables, in `.env`

| variable | description |
| ------ | ------ |
| MONGO_URI | mongo host URI |
| AZURE_SA | Azure Storage account name |
| AZURE_BLOB_CONTAINER | name of the azure storage blob container |
| AZURE_SHARE_NAME | name of the azure file share |
| AZURE_DESTINATION_KEY | azure storage account destination key |
| DB | name of mongo database to backup |
| MONGO_USERNAME | username for mongodb |
| MONGO_PASSWORD | password to authenticate against mongodb |
| MONGO_AUTH_DB | name of mongo authentication database |

You should specify either `AZURE_BLOB_CONTAINER` for blob storage or `AZURE_SHARE_NAME` for a file share.

### delayed start

When the container starts it will connect to mongodb and execute the backup process. To override this behaviour change the entrypoint to `cat` in your compose file.
You can then `exec` into the container and start the backup with the `./backup_mongo.sh` script.

## command line

Run the backup directly with `docker run` or by using the `run.sh` script as follows:

| argument | description |
| ------ | ------ |
| -u *or* --url  | mongo host URI |
| --sa | Azure Storage account name |
| -c *or* --blob-container | name of the azure storage blob container |
| -s *or* --share-name | name of the azure file share |
| -k *or* --key | azure storage account destination key |
| --db | name of mongo database to backup |
| -n *or* --username | username for mongodb |
| -p *or* --password | password to authenticate against mongodb |
| -a *or* --auth-db | name of mongo authentication database |
