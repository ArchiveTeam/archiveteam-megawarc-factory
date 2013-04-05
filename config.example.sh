#!/bin/bash
# Create this config.sh and copy it to the working directories of the
# packing and upload scripts.

echo "config.sh not customised."
exit 1

# your Archive.org S3 keys
IA_AUTH="ACCESS_KEY:SECRET"

# the name of the collection to add the uploads to
IA_COLLECTION="archiveteam_TODO"

# the title of the items (" ${item_timestamp}" will be appended)
IA_ITEM_TITLE="Archive Team TODO:"

# the prefix of the item name ("${item_timestamp}" is appended)
IA_ITEM_PREFIX="archiveteam_todo_"

# the prefix of the megawarc filename ("${item_timestamp}" is appended)
FILE_PREFIX="todo_"

# the date field for the item
IA_ITEM_DATE="2013-04"

