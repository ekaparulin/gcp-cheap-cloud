gcp_project   = "PROJECT_NAME"
gcp_region    = "europe-north1"
vpc_network       = "MY_NETWORK"
vpc_subnetwork        = "MY_SUBNETWORK"
vpc_subnetwork_cidr = "MY_CIDR"


instance_count = 1
instance_start = "0 8 * * *"
instance_stop  = "0 23 * * *"
time_zone = "Europe/Helsinki"
instance_name = "MY_INSTANCE_NAME"

image = "MY_ARCH_IMAGE"

machine_type   = "e2-micro"

tags           = [ "ssh" ]

init_scripts   = [ "update.sh", "dns.sh", "peervpn.sh" ]

dns_zone = "MY_DNS_MANAGED_ZONE"
dns_names = [ "MY_DNS_NAME_1", "MY_DNS_NAME_2" ]