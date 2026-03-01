# --- TERRAFORM ---
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.2"
    }
  }
}

provider "docker" {}

# --- NETWORK ---
# 1. Create a Virtual Network
resource "docker_network" "monitoring_network" {
  name = "monitoring_network"
}

# --- GRAFANA ---
resource "docker_image" "grafana_image" {
  name = "grafana/grafana:latest"
  keep_locally = true
}

resource "docker_container" "grafana_service" {
  image = docker_image.grafana_image.image_id
  name  = "my-terraform-grafana"
  ports {
    internal = 3000
    external = 3000
  }
  # --- GRAFANA NETWORK ---
  networks_advanced {
    name = docker_network.monitoring_network.name
  }
}

# --- PROMETHEUS ---
resource "docker_image" "prometheus_image" {
  name = "prom/prometheus:latest"
  keep_locally = true
}

resource "docker_container" "prometheus_service" {
  image = docker_image.prometheus_image.image_id
  name  = "my-terraform-prometheus"
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = "${abspath(path.cwd)}/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }
  # ---PROMETHEUS NETWORK---
  networks_advanced {
    name = docker_network.monitoring_network.name
  }
}