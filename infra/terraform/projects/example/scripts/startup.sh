#!/bin/bash

yay -Suy --noconfirm
yay -Sy --noconfirm wget jq

BUCKET=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/script_bucket" -H "Metadata-Flavor: Google")
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
gsutil cp -r "$BUCKET/$INSTANCE_NAME" /tmp 
find /tmp/$INSTANCE_NAME/init -type f -exec bash {} \;

