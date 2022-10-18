#!/bin/bash

BUCKET=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/script_bucket" -H "Metadata-Flavor: Google")
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")


cd /opt/docker-mail-server/
tar cvfz docker-mail-server.tar.gz data
gsutil cp -r /opt/docker-mail-server/docker-mail-server.tar.gz "$BUCKET/$INSTANCE_NAME/backups/" 

cd /etc/letsencrypt
tar cvfz - * | base64 > /tmp/letsencrypt
gcloud secrets versions add letsencrypt --data-file=/tmp/letsencrypt