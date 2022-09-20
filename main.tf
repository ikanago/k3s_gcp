terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "zone" {
  type    = string
  default = "us-west1-a"
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "random_id" "server_instance_id" {
  byte_length = 8
}

resource "random_id" "agent_instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "server_node" {
  name         = "server-${random_id.server_instance_id.hex}"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
    }
  }

  network_interface {
    network = "k3s"

    # This attribute is necessary to create NAT mapping this instance's IP to external one.
    access_config {}
  }

  depends_on = [
    google_compute_network.k3s
  ]
}

resource "google_compute_instance" "agent_node" {
  name         = "agent-${random_id.agent_instance_id.hex}"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
    }
  }

  network_interface {
    network = "k3s"

    access_config {}
  }

  depends_on = [
    google_compute_network.k3s
  ]
}

resource "google_compute_network" "k3s" {
  name = "k3s"
}

resource "google_compute_firewall" "icmp" {
  name          = "k3s-allow-icmp"
  network       = "k3s"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  depends_on = [
    google_compute_network.k3s
  ]
}

resource "google_compute_firewall" "ssh" {
  name          = "k3s-allow-ssh-from-iap"
  network       = "k3s"
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.k3s
  ]
}

resource "google_compute_firewall" "internal" {
  name          = "k3s-allow-internal"
  network       = "k3s"
  direction     = "INGRESS"
  source_ranges = ["10.128.0.0/9"]

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  depends_on = [
    google_compute_network.k3s
  ]
}
