locals {
  controlplane_virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.0.21"
      cpu_cores    = 8
      memory       = 18432
      hostpci      = ["ceph1"]
      gpu          = ["gpu"]
      usb          = []
    }
    k8s-2 = {
      ipv4_address = "192.168.0.22"
      cpu_cores    = 8
      memory       = 18432
      hostpci      = ["ceph2"]
      gpu          = []
      usb          = ["zigbee"]
    }
    k8s-3 = {
      ipv4_address = "192.168.0.23"
      cpu_cores    = 8
      memory       = 18432
      hostpci      = ["ceph3"]
      gpu          = []
      usb          = []
    }
  }
}

locals {
  # renovate: datasource=docker depName=ghcr.io/siderolabs/installer
  talos_version = "v1.11.1"

  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kubernetes_version = "v1.34.1"

  talos_install_image_config_patch = yamlencode({
    machine = {
      install = {
        image = data.talos_image_factory_urls.this.urls.installer
      }
    }
  })
}
