locals {
  virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.1.21/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-2 = {
      ipv4_address = "192.168.1.22/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-3 = {
      ipv4_address = "192.168.1.23/24"
      cpu_cores    = 2
      memory       = 2048
    }
    k8s-4 = {
      ipv4_address = "192.168.1.24/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-5 = {
      ipv4_address = "192.168.1.25/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-6 = {
      ipv4_address = "192.168.1.26/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-7 = {
      ipv4_address = "192.168.1.27/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-8 = {
      ipv4_address = "192.168.1.28/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-9 = {
      ipv4_address = "192.168.1.29/24"
      cpu_cores    = 1
      memory       = 1024
    }
    k8s-10 = {
      ipv4_address = "192.168.1.30/24"
      cpu_cores    = 1
      memory       = 1024
    }
  }
}

locals {
  talos_install_image_config_patch = yamlencode({
    machine = {
      install = {
        image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.0"
      }
    }
  })

  talos_vip_config_patch = yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            interface = "eth0"
            vip = {
              ip = "192.168.1.20"
            }
          }
        ]
      }
    }
  })

  talos_sysctls_config_patch = yamlencode({
    machine = {
      sysctls = {
        "fs.inotify.max_queued_events"  = "65536"
        "fs.inotify.max_user_watches"   = "524288"
        "fs.inotify.max_user_instances" = "8192"
      }
    }
  })
}

locals {
  controlplane_virtual_machines = {
    k8s_1 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-1"].name
      endpoint = "192.168.1.21"
    }
    k8s_2 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-2"].name
      endpoint = "192.168.1.22"
    }
    k8s_3 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-3"].name
      endpoint = "192.168.1.23"
    }
  }

  worker_virtual_machines = {
    k8s_4 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-4"].name
      endpoint = "192.168.1.24"
    }
    k8s_5 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-5"].name
      endpoint = "192.168.1.25"
    }
    k8s_6 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-6"].name
      endpoint = "192.168.1.26"
    }
    k8s_7 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-7"].name
      endpoint = "192.168.1.27"
    }
    k8s_8 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-8"].name
      endpoint = "192.168.1.28"
    }
    k8s_9 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-9"].name
      endpoint = "192.168.1.29"
    }
    k8s_10 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-10"].name
      endpoint = "192.168.1.30"
    }
  }
}
