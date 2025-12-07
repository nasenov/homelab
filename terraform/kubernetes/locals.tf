locals {
  controlplane_virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.0.21"
      cpu_cores    = 4
      memory       = 16384
      hostpci      = ["ceph1"]
      gpu          = ["gpu"]
      usb          = []
    }
    k8s-2 = {
      ipv4_address = "192.168.0.22"
      cpu_cores    = 4
      memory       = 16384
      hostpci      = ["ceph2"]
      gpu          = []
      usb          = ["zigbee"]
    }
    k8s-3 = {
      ipv4_address = "192.168.0.23"
      cpu_cores    = 4
      memory       = 16384
      hostpci      = ["ceph3"]
      gpu          = []
      usb          = []
    }
  }
}
