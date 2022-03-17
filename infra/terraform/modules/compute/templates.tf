data "template_file" "startup-script" {
  template =<<-EOT
   INIT_BUCKET=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/init_bucket" -H "Metadata-Flavor: Google")
   INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
   gsutil cp -r "$INIT_BUCKET/$INSTANCE_NAME" /tmp 
   find /tmp/$INSTANCE_NAME -type f -exec bash {} \;


   #rm -rf /tmp/$INSTANCE_NAME
EOT
}
