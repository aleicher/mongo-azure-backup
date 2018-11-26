# backup mongodb in azure storage

A little helper to create a backup of a mongodb using `mongodump`, storing the dump in azure blob storage using `azcopy`.

Tools used:

 - [azcopy](https://docs.microsoft.com/de-de/azure/storage/common/storage-use-azcopy-linux)
 - [mongodump](https://docs.mongodb.com/manual/reference/program/mongodump/)


# setup & usage

make sure you set the following environment variables, in `.env`

| variable | description |
| ------ | ------ |
| MONGO_URI | mongo host URI |
| AZURE_SA | Azure Storage account name |
| AZURE_BLOB_CONTAINER | name of the azure storage blob container |
| AZURE_DESTINATION_KEY | azure storage account destination key |
| DB | name of mongo database to backup |


run `./backup_mongo.sh` inside the container
