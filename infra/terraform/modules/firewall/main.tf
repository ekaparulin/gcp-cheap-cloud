resource "google_compute_firewall" "ssh" {

  name    = "${var.network}-allow-ssh"
  network = var.network

  target_tags = [
    "ssh"
  ]

  allow {
    protocol = "tcp"
    ports    = [    
      "22"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}
resource "google_compute_firewall" "http" {

  name    = "${var.network}-allow-http"
  network = var.network

  target_tags = [
    "http"
  ]

  allow {
    protocol = "tcp"
    ports    = [    
      "80"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}
resource "google_compute_firewall" "https" {

  name    = "${var.network}-allow-https"
  network = var.network

  target_tags = [
    "https"
  ]

  allow {
    protocol = "tcp"
    ports    = [    
      "443"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}


resource "google_compute_firewall" "peervpn" {

  name    = "${var.network}-allow-peervpn"
  network = var.network

  target_tags = [
    "peervpn"
  ]

  allow {
    protocol = "udp"
    ports    = [    
      "7000"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}

resource "google_compute_firewall" "wireguard" {

  name    = "${var.network}-allow-wireguard"
  network = var.network

  target_tags = [
    "wireguard"
  ]

  allow {
    protocol = "udp"
    ports    = [    
      "51820"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}

resource "google_compute_firewall" "mail-server" {

  name    = "${var.network}-allow-mail-server"
  network = var.network

  target_tags = [
    "mail-server"
  ]

  allow {
    protocol = "tcp"
    ports    = [    
      "25",
      "143",
      "465",
      "587",
      "993"
    ]
  }

  source_ranges = [
      var.source_cidr
  ]
}



