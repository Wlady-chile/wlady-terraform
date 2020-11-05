provider "google" {
  version = "3.5.0"

  project = var.project
  region  = var.region
  zone    = var.zone
}

#resource "google_compute_network" "vpc_network" {
#  name = "terraform-wbp"
#  auto_create_subnetwork = false   
#}

resource "google_compute_instance" "vm_instance" {
  name         = "wladimir-instance"
  machine_type = var.machine_types[var.environment]
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}

resource "google_compute_address" "vm_static_ip" {
    name = "wladimir-static-ip"
}

# New resource for the storage bucket our application will use.
resource "google_storage_bucket" "example_bucket" {
  name     = "wbp_bucket"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Create a new instance that uses the bucket
resource "google_compute_instance" "another_instance" {
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]

  name         = "wladimir-instance-2"
  machine_type = var.machine_types[var.environment]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
