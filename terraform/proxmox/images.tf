resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  node_name          = "pve"
  datastore_id       = "local"
  content_type       = "iso"
  url                = "https://cloud-images.ubuntu.com/releases/24.04/release-20240911/ubuntu-24.04-server-cloudimg-amd64.img"
  checksum_algorithm = "sha256"
  checksum           = "78547d336e4c8f98864fd3088a7ab393d7ab970885263578404bad7fc7c5e5d8"
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "snippets"

  source_raw {
    file_name = "vendorconfig.yaml"
    data      = <<EOF
#cloud-config
runcmd:
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF
  }
}

resource "proxmox_virtual_environment_download_file" "truenas" {
  node_name          = "pve"
  datastore_id       = "local"
  content_type       = "iso"
  url                = "https://download.sys.truenas.net/TrueNAS-SCALE-Dragonfish/24.04.2.2/TrueNAS-SCALE-24.04.2.2.iso"
  checksum_algorithm = "sha256"
  checksum           = "1ba1805a7a579a7d8313764b1e11b4b10d00e861def45ba2880f3049a6b0e354"
}

resource "proxmox_virtual_environment_download_file" "talos" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "iso"
  file_name    = "nocloud-amd64.img"
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.0/nocloud-amd64.raw"
}
