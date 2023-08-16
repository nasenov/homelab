resource "proxmox_vm_qemu" "truenas" {
  name        = "truenas"
  target_node = "debian"
  iso         = "local:iso/TrueNAS-SCALE-22.12.3.2.iso"

  agent = 1

  cpu     = "x86-64-v2-AES"
  sockets = 1
  cores   = 2
  memory  = 8192
  scsihw  = "virtio-scsi-single"
  bios     = "seabios"
  
  boot     = "order=scsi0;ide2;net0"
  onboot   = true
  oncreate = false
  qemu_os  = "l26"

  network {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "16G"
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "64G"
  }

  disk {
    type    = "ide"
    storage = "local"
    size    = "1713872K"
  }

  hostpci {
    host   = "0000:07:00.0"
    rombar = 0
  }

}
