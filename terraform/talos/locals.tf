locals {
  controlplanes = {
    k8s-1 = {
      install_disk_serial = "S41GNX3M622390",
      ipv4_address        = "192.168.0.121"
    }
    k8s-2 = {
      install_disk_serial = "192416806849",
      ipv4_address        = "192.168.0.122"
    }
    k8s-3 = {
      install_disk_serial = "BTPY72110CB6256D",
      ipv4_address        = "192.168.0.123"
    }
  }

  endpoints = [for controlplane in local.controlplanes : controlplane.ipv4_address]
}
