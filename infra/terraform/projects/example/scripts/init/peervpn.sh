#!/bin/bash

yay -Suy peervpn

gcloud secrets versions access latest --secret="peervpn" > /etc/peervpn.conf

cat << EOF > /etc/systemd/system/peervpn.service
[Unit]

Description=Peervpn
After=network.target
Wants=network-online.target

[Service]

Restart=always
Type=simple
ExecStart=/usr/bin/peervpn /etc/peervpn.conf
Environment=

[Install]
WantedBy=multi-user.target

EOF

systemctl enable peervpn
systemctl start peervpn

