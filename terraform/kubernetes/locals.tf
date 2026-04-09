locals {
  controlplanes = {
    k8s-1 = {
      ipv4_address = "192.168.0.121"
    }
    k8s-2 = {
      ipv4_address = "192.168.0.122"
    }
    k8s-3 = {
      ipv4_address = "192.168.0.123"
    }
  }

  endpoints = [for controlplane in local.controlplanes : controlplane.ipv4_address]
}
