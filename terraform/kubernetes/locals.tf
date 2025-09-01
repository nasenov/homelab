locals {
  controlplane_virtual_machines = {
    k8s-1 = {
      ipv4_address = "192.168.0.21"
      cpu_cores    = 8
      memory       = 16384
      hostpci      = ["ceph1"]
      gpu          = ["gpu"]
      usb          = []
    }
    k8s-2 = {
      ipv4_address = "192.168.0.22"
      cpu_cores    = 8
      memory       = 16384
      hostpci      = ["ceph2"]
      gpu          = []
      usb          = ["zigbee"]
    }
    k8s-3 = {
      ipv4_address = "192.168.0.23"
      cpu_cores    = 8
      memory       = 16384
      hostpci      = ["ceph3"]
      gpu          = []
      usb          = []
    }
  }
}

locals {
  # renovate: datasource=docker depName=ghcr.io/siderolabs/installer
  talos_version = "v1.11.0"

  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  kubernetes_version = "v1.34.0"

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
        "net.core.rmem_max"             = 7500000 # Cloudflared / QUIC
        "net.core.wmem_max"             = 7500000 # Cloudflared / QUIC
      }
    }
  })

  talos_kernel_modules_config_patch = yamlencode({
    machine = {
      kernel = {
        modules = [{ name = "nbd" }]
      }
    }
  })

  talos_kubelet_config_patch = yamlencode({
    machine = {
      kubelet = {
        extraArgs = {
          serialize-image-pulls = false
        }
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
        [plugins."io.containerd.cri.v1.runtime"]
          device_ownership_from_security_context = true          
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
        admissionControl = [
          {
            name     = "PodSecurity"
            "$patch" = "delete"
          }
        ]
        resources = {
          requests = {
            cpu    = "200m"
            memory = "1500Mi"
          }
          limits = {
            memory = "1500Mi"
          }
        }
      }
    }
  })

  talos_cluster_coredns_config_patch = yamlencode({
    cluster = {
      coreDNS = {
        disabled = true
      }
    }
  })

  talos_cluster_control_plane_scheduling = yamlencode({
    cluster = {
      allowSchedulingOnControlPlanes = true
    }
  })

  talos_user_volume_config_patch = yamlencode({
    apiVersion = "v1alpha1"
    kind       = "UserVolumeConfig"
    name       = "openebs"
    provisioning = {
      diskSelector = {
        match = "disk.transport == 'virtio' && !system_disk"
      }
      minSize = "64GB"
      grow    = true
    }
  })
}
