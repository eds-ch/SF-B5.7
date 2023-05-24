########## General

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "tf-state-bucket-mentor-eds"
    region   = "ru-central1-a"
    key      = "issue1/lemp.tfstate"
    # Данный провайдер хранит ключи авторизации и базовый настройки в папке ~/.aws
    # Также можно держать их и в данном файле с параметрами ниже
    #    access_key = "key"
    #    secret_key = "key"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  # Ключ можно сгенерировать в кабинете или утилитой yc. В ключе хранится ID и Secret key
  service_account_key_file = file("~/ya-key.json")
  folder_id                = "b1g8g8q0m64noo4k8rc2"
  zone                     = "ru-central1-a" # зона, которая будет использована по умолчанию
}

module "sf-inst-1" {
  source                = "./modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = module.loadbalancer.yandex_vpc_subnet
}

module "sf-inst-2" {
  source                = "./modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = module.loadbalancer.yandex_vpc_subnet
}


module "loadbalancer" {
  source       = "./modules/loadbalancer"
  sf-inst-1-ip = module.sf-inst-1.internal_ip_address_vm
  sf-inst-2-ip = module.sf-inst-2.internal_ip_address_vm
}


