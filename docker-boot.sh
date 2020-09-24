#!/bin/bash

 set -e

 test -d /data || {
        echo "No /data mount found"
        exit 1
}

 mkdir -p /data/incoming /data/chunker-work /data/packing-queue /data/packer-work-in /data/packer-work-out /data/upload-queue /data/uploader-work

 IA_ITEM_DATE_LIT='$( date +"%Y-%m" )'
cat > /factory/config.sh << EOF
#!/bin/bash
MEGABYTES_PER_CHUNK="${MEGABYTES_PER_CHUNK}"
IA_AUTH="${IA_AUTH}"
IA_COLLECTION="${IA_COLLECTION}"
IA_ITEM_TITLE="${IA_ITEM_TITLE}"
IA_ITEM_PREFIX="${IA_ITEM_PREFIX}"
FILE_PREFIX="${FILE_PREFIX}"
IA_ITEM_DATE="${IA_ITEM_DATE_LIT}"
OFFLOAD_TARGET="${OFFLOAD_TARGET}"
ZST_DICTIONARY_API="${ZST_DICTIONARY_API}"
LOAD_BALANCER="${LOAD_BALANCER}"
INCOMING_UPLOADS_DIR="/data/incoming"
CHUNKER_WORKING_DIR="/data/chunker-work"
PACKING_QUEUE_DIR="/data/packing-queue"
PACKER_WORKING_CHUNKS_DIR="/data/packer-work-in"
PACKER_WORKING_MEGAWARC_DIR="/data/packer-work-out"
UPLOAD_QUEUE_DIR="/data/upload-queue"
UPLOADER_WORKING_DIR="/data/uploader-work"
COMPLETED_DIR=""
EOF

 touch /factory/RUN

 case "${1}" in
        chunk|chunker|chunk-multiple)
                if test -z "${MEGABYTES_PER_CHUNK}"; then
                        echo "Missing param: MEGABYTES_PER_CHUNK=${MEGABYTES_PER_CHUNK}"
                        exit 1
                fi
                exec /factory/chunk-multiple
        ;;
        pack|pack-one|packer|pack-multiple)
                if test -z "${FILE_PREFIX}" || test -z "${ZST_DICTIONARY_API}"; then
                        echo "Missing param: FILE_PREFIX=${FILE_PREFIX} ZST_DICTIONARY_API=${ZST_DICTIONARY_API}"
                        exit 1
                fi
                exec /factory/pack-multiple
        ;;
        upload|upload-one|upload-multiple)
                if test -z "${IA_AUTH}" || test -z "${IA_COLLECTION}" || test -z "${IA_ITEM_TITLE}" || test -z "${IA_ITEM_PREFIX}" || test -z "${FILE_PREFIX}"; then
                        echo "Missing param: IA_AUTH=${IA_AUTH} IA_COLLECTION=${IA_COLLECTION} IA_ITEM_TITLE=${IA_ITEM_TITLE} IA_ITEM_PREFIX=${IA_ITEM_PREFIX} FILE_PREFIX=${FILE_PREFIX}"
                        exit 1
                fi
                exec /factory/upload-multiple
        ;;
        offload|offload-one|offload-multiple)
                if test -z "${OFFLOAD_TARGET}" && ! test -f "${PWD}/offload_targets"; then
                        echo "Missing param: OFFLOAD_TARGET=${OFFLOAD_TARGET} and no ${PWD}/offload_targets existing"
                        exit 1
                fi
                exec /factory/offload-multiple
        ;;
        *)
                echo "Usage: chunk|pack|upload|offload"
                exit 1
        ;;
esac
