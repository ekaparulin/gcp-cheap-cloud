#!/bin/bash

EXTERNAL_IP=$(curl -H "Metadata-Flavor: Google" "http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip")
DNS_NAMES=$(curl  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/dns_names")
DNS_ZONE=$(curl  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/dns_zone")
  
for NAME in $( echo $DNS_NAMES | sed "s/,/ /g" )
do 
    CMD=create
    gcloud dns record-sets describe $NAME -z $DNS_ZONE --type A && CMD=update

    gcloud dns record-sets $CMD $NAME \
        --rrdatas=$EXTERNAL_IP \
        --ttl=30 \
        --type=A \
        --zone=$DNS_ZONE
done
