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
    data = <<EOF
#cloud-config
runcmd:
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF
  }
}
