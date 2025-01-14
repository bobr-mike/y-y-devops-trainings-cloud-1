terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "/home/GROUPS7/m.bobrov/terra/yc_terraform.json"
  folder_id                = "b1gq9bf3fsaruca2p7t8"
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "foo" {}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_container_registry" "registry1" {
  name = "registry1"
}

locals {
  folder_id = "b1gq9bf3fsaruca2p7t8"
  service-accounts = toset([
    "bobr-catgpt-sa",
  ])
  catgpt-sa-roles = toset([
    "container-registry.images.puller",
    "monitoring.editor",
  ])
}
resource "yandex_iam_service_account" "service-accounts" {
  for_each = local.service-accounts
  name     = each.key
}
resource "yandex_resourcemanager_folder_iam_member" "catgpt-roles" {
  for_each  = local.catgpt-sa-roles
  folder_id = local.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["bobr-catgpt-sa"].id}"
  role      = each.key
}

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}
resource "yandex_compute_instance" "catgpt-1" {
  platform_id        = "standard-v2"
  service_account_id = yandex_iam_service_account.service-accounts["bobr-catgpt-sa"].id
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.foo.id
    nat       = true
  }
  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = "30"
      image_id = data.yandex_compute_image.coi.id
    }
  }
  metadata = {
    docker-compose = file("${path.module}/docker-compose.yaml")
    ssh-keys       = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
    user-data      = "#cloud-config\nruncmd:\n  - wget -O - https://monitoring.api.cloud.yandex.net/monitoring/v2/unifiedAgent/config/install.sh | bash"

  }
}
resource "yandex_compute_instance" "catgpt-2" {
  platform_id        = "standard-v2"
  service_account_id = yandex_iam_service_account.service-accounts["bobr-catgpt-sa"].id
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.foo.id
    nat       = true
  }
  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = "30"
      image_id = data.yandex_compute_image.coi.id
    }
  }
  metadata = {
    docker-compose = file("${path.module}/docker-compose.yaml")
    ssh-keys       = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
    user-data      = "#cloud-config\nruncmd:\n  - wget -O - https://monitoring.api.cloud.yandex.net/monitoring/v2/unifiedAgent/config/install.sh | bash"

  }
}

