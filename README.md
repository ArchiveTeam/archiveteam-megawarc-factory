Archive Team megawarc factory
=============================
Some scripts to bundle Archive Team uploads and upload them to Archive.org. Use at your own risk; the scripts will need per-project adjustment.

These scripts make batches of uploaded warc.gz files, combine them into megawarcs and upload them to their permanent home on Archive.org.

Three main processes work together to make this happen:

1. The chunker
--------------
The chunker moves uploaded warc.gz files from the upload directory to a batch directory. When this directory has grown to 50GB (or the size defined), the chunker begins a new directory and moves the completed directory to the packing queue.

There can only be one chunker per upload directory. Chunking doesn't take long, if the files are not moving to a different filesystem.

2. The packer
-------------
The packer monitors the packing queue. When the chunker brings a new directory, the packer removes the directory from the queue and starts converting it into a megawarc (using the megawarc utility). When that is done, the packer moves the megawarc to the upload queue and removes the original warc files.

If necessary, multiple packers can work the same queue. Packing involves lots of gzipping and takes some time.

3. The uploader
---------------
The uploader monitors the upload queue. When the packer brings a new megawarc, the uploader removes the megawarc from the queue and uploads it to Archive.org. If the upload is successful, the uploader removes the megawarc.

If necessary, multiple uploaders can work the same queue.

4. The offloader
---------------
The offloader monitors the upload queue. Instead of uploading to Archive.org, the megawarc will be sent to another host via rsync. This is useful when Archive.org has issues. 

This can be used at the same time as the uploader without issues.


Configuration
-------------
Create a configuration file called `config.sh` and place it in the directory where you start the scripts. See the `config.example.sh` for more details.


Running in Docker (RECOMMENDED)
-------------
```
IA_COLLECTION="archiveteam_inbox"
IA_ITEM_TITLE="Archive Team PROJECT:"
IA_ITEM_PREFIX="archiveteam_PROJECT_"
FILE_PREFIX="PROJECT_"
IA_AUTH="no:thanks"
MEGABYTES_PER_CHUNK="$((25*1024))"
ZST_DICTIONARY_API="http://trackerproxy.archiveteam.org:25654/dictionary"
docker run -d -e MAX_CONN=100 -e PORT=8873 --network=host -v target:/data/ --name target-rsync warcforceone/ateam-airsync
docker run --name "target-chunker" -d  -v target:/data/ -e MEGABYTES_PER_CHUNK="${MEGABYTES_PER_CHUNK}" warcforceone/megawarc-factory chunk
docker run --name "target-packer1" -d  -v target:/data/ -e FILE_PREFIX="${FILE_PREFIX}" -e ZST_DICTIONARY_API="${ZST_DICTIONARY_API}" warcforceone/megawarc-factory pack
docker run --name "target-uploader1" -d  -v target:/data/ -e IA_AUTH="${IA_AUTH}" -e IA_COLLECTION="${IA_COLLECTION}" -e IA_ITEM_TITLE="${IA_ITEM_TITLE}" -e IA_ITEM_PREFIX="${IA_ITEM_PREFIX}" -e FILE_PREFIX="${FILE_PREFIX}" warcforceone/megawarc-factory upload
```
Multiple packers, uploaders and offloaders able to be used, only a single rsync and chunker should be used.
To run a offload instance
```
docker run --name "target-offload" -d -v target:/data/ -e OFFLOAD_TARGET="rsync://offload-target" archiveteam-factory offload
```
### Variables for instances
#### target-rsync
DISK_LIMIT=75 - Limit in percent the target sets rsync connections to -1 (no new connections accepted)
DISK_HARD_LIMIT=90 - Limit in percent the target kills rsync to kill any existing connections
#### target-uploader
LOAD_BALANCER=s3-lb0 - Define loadbalancer you wish to connect to s3-lb1.us.archive.org becomes s3-lb1


Running traditional (NOT ADVISED)
-------
Run the scripts in `screen`, `tmux` or something similar. `touch RUN` before you start the scripts. Use `rm RUN` to stop gracefully.

* `./chunk-multiple` (run exactly one)
* `./pack-multiple` (you may run more than one)
* `./upload-multiple` (you may run more than one)
* `./offload-multiple` (you may run more than one, can work in tandem with `upload-multiple`)

Utility scripts:

* `./du-all` will run `du -hs` in all queues

Filesystems
-----------
From the chunker to the uploader, the chunks move through the system as timestamped directories, e.g., 20130401213900.) This timestamp will also be used in the name of the uploaded item on Archive.org. The queues are directories. Processes 'claim' a chunk by moving it from the queue directory to their working directory. This assumes that `mv` is an atomic operation.

For efficiency and to maintain the atomicity of `mv`, the filesystem of the directories is very important:

1. The Rsync upload directory, the chunker working directory, the packing queue and that side of the packer's working directory should all be on the same filesystem. This ensures that the uploaded warc.gz files never move to a different file system.
2. The megawarc side of the packer's working directory, the upload queue and the uploader's working directory should also share a filesystem.

Filesystems 1 and 2 do not have to be the same.

### Running dual filesystems with docker
Overall running dual FS with docker is very simple and easily done. The only container that requires access to both file systems is the packer. To make this simple inside the CT filesystem 1 (fs1) is mounted at /data and fs2 is mounted at /data2.

If /fs1 is filesystem 1 on the host node as well as /fs2 being filesystem 2 on the host node the packer would be ran as such;
```
docker run --name "target-packer1" -d  -v /fs1/target/:/data/ -v /fs2/target/:/data2/ -e FILE_PREFIX="${FILE_PREFIX}" -e ZST_DICTIONARY_API="${ZST_DICTIONARY_API}" warcforceone/megawarc-factory pack
```
All other containers can be ran as standard as seen above.

Scheduling priorities
---------------------
The packing script will use all your I/O capacity. Consider using `nice` and `ionice` to run in at a lower priority, so it doesn't hinder your incoming Rsync or outgoing curl uploads.

* `ionice -c 2 -n 6 nice -n 19 ./pack-multiple`


Recovering from errors
----------------------
The scripts are designed not to lose data. If a script dies, you can look in its working directory for in-progress items and move them back to the queue.


Requirements
------------
These scripts use Bash and Curl.

You should clone https://github.com/ArchiveTeam/megawarc to the `megawarc/` subdirectory of these scripts. The megawarc utility requires Python and Gzip.

