terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.84.0"
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
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["k3s"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 25
    }
  }

  network_interface {
    network = "default"

    # This attribute is necessary to create NAT mapping this instance's IP to external one.
    access_config {}
  }
}

resource "google_compute_instance" "agent_node" {
  name         = "agent-${random_id.agent_instance_id.hex}"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["k3s"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 25
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }
}

resource "google_compute_firewall" "k3s" {
  name        = "default-allow-k3s"
  network     = "default"
  direction   = "INGRESS"
  source_tags = ["k3s"]
  target_tags = ["k3s"]

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
}

