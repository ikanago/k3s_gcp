terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.2.1"
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
    network = "default"
  }
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
    network = "default"
  }
}

resource "google_compute_firewall" "ssh" {
  name          = "allow-ssh-from-iap"
  network       = "default"
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
