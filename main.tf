terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.2.1"
    }
  }
}

variable "project" {
  type = string
}

variable "region" {
  type = string
  default = "us-west1"
}

variable "zone" {
  type = string
  default = "us-west1-a"
}

provider "google" {
  project     = var.project
  region      = var.region
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "dev_env" {
  name = "dev-env-${random_id.instance_id.hex}"
  machine_type = "e2-micro"
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh-from-iap"
  network = "default"
  direction = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}
