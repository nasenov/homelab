locals {
  virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.0.21/24"
      cpu_cores    = 4
      memory       = 4096
      hostpci      = []
      gpu          = []
      usb          = []
    }
    k8s-2 = {
      ipv4_address = "192.168.0.22/24"
      cpu_cores    = 4
      memory       = 4096
      hostpci      = []
      gpu          = []
      usb          = []
    }
    k8s-3 = {
      ipv4_address = "192.168.0.23/24"
      cpu_cores    = 4
      memory       = 4096
      hostpci      = []
      gpu          = []
      usb          = []
    }
    k8s-4 = {
      ipv4_address = "192.168.0.24/24"
      cpu_cores    = 4
      memory       = 8192
      hostpci      = ["0000:01:00"]
      gpu          = []
      usb          = []
    }
    k8s-5 = {
      ipv4_address = "192.168.0.25/24"
      cpu_cores    = 4
      memory       = 8192
      hostpci      = ["0000:02:00"]
      gpu          = []
      usb          = []
    }
    k8s-6 = {
      ipv4_address = "192.168.0.26/24"
      cpu_cores    = 4
      memory       = 8192
      hostpci      = ["0000:09:00"]
      gpu          = []
      usb          = []
    }
    k8s-7 = {
      ipv4_address = "192.168.0.27/24"
      cpu_cores    = 4
      memory       = 12288
      hostpci      = []
      gpu          = ["0000:00:02"]
      usb          = ["10c4:ea60"]
    }
    k8s-8 = {
      ipv4_address = "192.168.0.28/24"
      cpu_cores    = 4
      memory       = 12288
      hostpci      = []
      gpu          = []
      usb          = []
    }
    k8s-9 = {
      ipv4_address = "192.168.0.29/24"
      cpu_cores    = 4
      memory       = 8192
      hostpci      = []
      gpu          = []
      usb          = []
    }
    k8s-10 = {
      ipv4_address = "192.168.0.30/24"
      cpu_cores    = 4
      memory       = 8192
      hostpci      = []
      gpu          = []
      usb          = []
    }
  }
}

locals {
  talos_install_image_config_patch = yamlencode({
    machine = {
      install = {
        image = data.talos_image_factory_urls.this.urls.installer
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
              ip = "192.168.0.20"
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

  talos_kubelet_config_patch = yamlencode({
    machine = {
      kubelet = {
        extraArgs = {
          rotate-server-certificates = true
        }
        extraMounts = [{
          destination = "/var/openebs/local"
          type        = "bind"
          source      = "/var/openebs/local"
          options     = ["bind", "rshared", "rw"]
        }]
      }
    }
  })

  talos_containerd_config_patch = yamlencode({
    machine = {
      files = [{
        path    = "/etc/cri/conf.d/20-customization.part"
        op      = "create"
        content = <<-EOT
        [plugins."io.containerd.cri.v1.images"]
          discard_unpacked_layers = false
        EOT
      }]
    }
  })

  talos_kubernetes_talos_api_access_config_patch = yamlencode({
    machine = {
      features = {
        kubernetesTalosAPIAccess = {
          enabled                     = true
          allowedRoles                = ["os:admin"]
          allowedKubernetesNamespaces = ["system-upgrade"]
        }
      }
    }
  })

  talos_cluster_network_config_patch = yamlencode({
    cluster = {
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  })

  talos_discovery_service_patch = yamlencode({
    cluster = {
      discovery = {
        enabled = true
        registries = {
          service = {
            disabled = true
          }
          kubernetes = {
            disabled = false
          }
        }
      }
    }
  })

  talos_cluster_controller_manager_config_patch = yamlencode({
    cluster = {
      controllerManager = {
        extraArgs = {
          bind-address = "0.0.0.0"
        }
      }
    }
  })

  talos_cluster_scheduler_config_patch = yamlencode({
    cluster = {
      scheduler = {
        extraArgs = {
          bind-address = "0.0.0.0"
        }
      }
    }
  })

  talos_cluster_etcd_config_patch = yamlencode({
    cluster = {
      etcd = {
        extraArgs = {
          listen-metrics-urls = "http://0.0.0.0:2381"
        }
      }
    }
  })

  talos_cluster_apiserver_config_patch = yamlencode({
    cluster = {
      apiServer = {
        disablePodSecurityPolicy = true
      }
    }
  })
}

locals {
  controlplane_virtual_machines = {
    k8s_1 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-1"].name
      endpoint = "192.168.0.21"
    }
    k8s_2 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-2"].name
      endpoint = "192.168.0.22"
    }
    k8s_3 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-3"].name
      endpoint = "192.168.0.23"
    }
  }

  worker_virtual_machines = {
    k8s_4 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-4"].name
      endpoint = "192.168.0.24"
    }
    k8s_5 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-5"].name
      endpoint = "192.168.0.25"
    }
    k8s_6 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-6"].name
      endpoint = "192.168.0.26"
    }
    k8s_7 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-7"].name
      endpoint = "192.168.0.27"
    }
    k8s_8 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-8"].name
      endpoint = "192.168.0.28"
    }
    k8s_9 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-9"].name
      endpoint = "192.168.0.29"
    }
    k8s_10 = {
      node     = proxmox_virtual_environment_vm.k8s["k8s-10"].name
      endpoint = "192.168.0.30"
    }
  }
}
