resource "proxmox_virtual_environment_vm" "k3s" {
  for_each  = var.k3s_nodes
  name      = each.key
  node_name = var.node_name
  vm_id     = each.value.vm_id

  clone {
    vm_id = var.template_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id        = "local-lvm"
    vendor_data_file_id = "local:snippets/k3s-vendor.yaml"

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }

    user_account {
      username = "henry"
      keys     = [var.ssh_public_key]
    }
  }
}
