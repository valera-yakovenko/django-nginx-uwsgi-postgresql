#!/bin/bash
 
pg_basebackup --format=t -z -X fetch -D /tmp/pg_backup/backup-$(date +"%T:%A:%d:%m:%y")

