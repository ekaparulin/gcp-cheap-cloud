gcp_project   = "eugener-one"
gcp_region    = "europe-north1"
vpc_network       = "eugener-one-network"
vpc_subnetwork        = "eugen-net"
vpc_subnetwork_cidr = "10.8.79.0/24"


instance_count = 1
instance_start = "0 8 * * *"
instance_stop  = "0 23 * * *"
time_zone = "Europe/Helsinki"
instance_name = "edge"

image = "eugener-one/arch-linux-v20221007-1"

machine_type   = "e2-micro"
tags           = [ "ssh", "https", "peervpn", "wireguard" ]

init_scripts   = [ "update.sh", "dns.sh",  "peervpn.sh", "wireguard.sh"  ]

dns_zone = "eugener-one"
dns_names = [ "remote.eugener.one" ]