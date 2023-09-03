resource "proxmox_vm_qemu" "k3s-1" {
  name        = "k3s-1"
  target_node = "debian"

  memory  = 8192
  sockets = 1
  cores   = 4
  cpu     = "host"
  scsihw  = "virtio-scsi-pci"

  onboot  = true
  qemu_os = "l26"

  clone      = "ubuntu-lunar"
  os_type    = "cloud-init"
  full_clone = true
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.sshkeys
  ipconfig0  = "ip=192.168.1.130/24,gw=192.168.1.1"

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "54784M"
  }

}

resource "proxmox_vm_qemu" "k3s-2" {
  name        = "k3s-2"
  target_node = "debian"

  memory  = 8192
  sockets = 1
  cores   = 4
  cpu     = "host"
  scsihw  = "virtio-scsi-pci"

  onboot  = true
  qemu_os = "l26"

  clone      = "ubuntu-lunar"
  os_type    = "cloud-init"
  full_clone = true
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.sshkeys
  ipconfig0  = "ip=192.168.1.131/24,gw=192.168.1.1"

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "54784M"
  }

  disk {
    type    = "scsi"
    storage = "longhorn-1"
    size    = "953G"
  }

}

resource "proxmox_vm_qemu" "k3s-3" {
  name        = "k3s-3"
  target_node = "debian"

  memory  = 8192
  sockets = 1
  cores   = 4
  cpu     = "host"
  scsihw  = "virtio-scsi-pci"

  onboot  = true
  qemu_os = "l26"

  clone      = "ubuntu-lunar"
  os_type    = "cloud-init"
  full_clone = true
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.sshkeys
  ipconfig0  = "ip=192.168.1.132/24,gw=192.168.1.1"

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "54784M"
  }

  disk {
    type    = "scsi"
    storage = "longhorn-2"
    size    = "953G"
  }

}

resource "proxmox_vm_qemu" "k3s-4" {
  name        = "k3s-4"
  target_node = "debian"

  memory  = 8192
  sockets = 1
  cores   = 4
  cpu     = "host"
  scsihw  = "virtio-scsi-pci"

  onboot  = true
  qemu_os = "l26"

  clone      = "ubuntu-lunar"
  os_type    = "cloud-init"
  full_clone = true
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.sshkeys
  ipconfig0  = "ip=192.168.1.133/24,gw=192.168.1.1"

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type    = "scsi"
    storage = "fast"
    size    = "54784M"
  }

  # TODO: replace with actual disk before migration
  disk {
    type    = "scsi"
    storage = "fast"
    size    = "54784M"
  }

}
