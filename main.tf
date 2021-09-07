terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = "variable-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"

}
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.name}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  network       = google_compute_network.vpc.name
  region        = var.region
}
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.name}-private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  network       = google_compute_network.vpc.name
  region        = var.region
}
#Allow SSH
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.name}-fw-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}

# allow http traffic
resource "google_compute_firewall" "allow-http" {
  name    = "${var.name}-fw-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"]
}
allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ftp"]
}

# allow https traffic
resource "google_compute_firewall" "allow-https" {
  name    = "${var.name}-fw-allow-https"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["https"]
}

resource "random_id" "instance_id" {
  byte_length = 4
}
# Create VM #1
resource "google_compute_instance" "vm_instance_public" {
  name         = "${var.name}-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["ssh", "http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  metadata_startup_script = "sudo apt-get update;sudo apt-get install -yq build-essential apache2"
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public_subnet.name

    access_config {}
  }
}
