#!/bin/bash
# Create a copy of this config.sh, customise it and place it in the
# working directory of the packing and upload scripts.

####################
# CHUNKER SETTINGS #
####################
# start a new chunk when the current chunk is at least this large
MEGABYTES_PER_CHUNK=$((1024*25))

###################
# UPLOAD METADATA #
###################
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
IA_ITEM_DATE=$( date +"%Y-%m" )

# offload items to another rsync storage instead of uploading to IA
OFFLOAD_TARGET="rsync://somewhere-far-away:portnum/module-name/directory/"
# it is also possible to create a list of targets and the offloader will pick one at random and retry others on failure
# simply comment out the line above and put all rsync target urls separated by newline in a file called "offload_targets"

# the API for requesting the ZSTD dictionaries
ZST_DICTIONARY_API="API_URL"

###############
# DIRECTORIES #
###############
# Put your directories on one or two filesystems (see README).
FS1_BASE_DIR="/archiveteam/ssd/project"
FS2_BASE_DIR="/archiveteam/disk/project"

## THESE DIRECTORIES ON FILESYSTEM 1: for warcs

# the rsync upload directory
# (the chunker will package the .warc.gz files in this directory)
INCOMING_UPLOADS_DIR="${FS1_BASE_DIR}/incoming-uploads"

# the chunker working directory
# (this directory will hold the current in-progress chunk)
CHUNKER_WORKING_DIR="${FS1_BASE_DIR}/chunker-work"

# the chunker output directory / the packer queue
# (this directory will hold the completed chunks)
PACKING_QUEUE_DIR="${FS1_BASE_DIR}/packing-queue"

# the packer working directory - warc side
# (this directory will hold the current chunk)
PACKER_WORKING_CHUNKS_DIR="${FS1_BASE_DIR}/packer-work-in"

## THESE DIRECTORIES ON FILESYSTEM 2: for megawarcs

# the packer working directory - megawarc side
# (this directory will hold the current megawarc)
PACKER_WORKING_MEGAWARC_DIR="${FS2_BASE_DIR}/packer-work-out"

# the packer output directory / the upload queue
# (this directory will hold the completed megawarcs)
UPLOAD_QUEUE_DIR="${FS2_BASE_DIR}/upload-queue"

# the uploader working directory
# (this directory will hold the current megawarc)
UPLOADER_WORKING_DIR="${FS2_BASE_DIR}/uploader-work"

# the final destination for uploaded megawarcs
# leave this empty to remove megawarcs after uploading
COMPLETED_DIR="${FS2_BASE_DIR}/uploaded"


# remove this
echo "config.sh not customised."
exit 1


