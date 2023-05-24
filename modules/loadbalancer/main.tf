terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

#### Load Balance Target Group


resource "yandex_vpc_network" "sf-test-network" {}

resource "yandex_vpc_subnet" "sf-test-subnet" {
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.sf-test-network.id}"
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_lb_target_group" "sf-test-lb-group" {
  name      = "sf-test-lb-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.sf-test-subnet.id}"
    address = var.sf-inst-1-ip
  }

  target {
    subnet_id = "${yandex_vpc_subnet.sf-test-subnet.id}"
    address = var.sf-inst-2-ip
  }
}

###### Load Balancer

resource "yandex_lb_network_load_balancer" "sf-test-lb" {
  name = "sf-test-load-balancer"

  listener {
    name = "sf-test-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.sf-test-lb-group.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
