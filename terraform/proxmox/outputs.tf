output "k3s_ips" {
  value = { for name, vm in proxmox_virtual_environment_vm.k3s : name => vm.ipv4_addresses }
}
