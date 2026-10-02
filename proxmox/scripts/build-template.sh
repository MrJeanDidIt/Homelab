#!/usr/bin/env bash
set -euo pipefail

VMID="${VMID:-9000}"
STORAGE="${STORAGE:-local-lvm}"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_DIR="/var/lib/vz/template/iso"
IMAGE_PATH="$IMAGE_DIR/noble-server-cloudimg-amd64.img"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET_SRC="$SCRIPT_DIR/../snippets/k3s-vendor.yaml"

if qm status "$VMID" >/dev/null 2>&1; then
  echo "VM $VMID already exists, remove it first with: qm destroy $VMID"
  exit 1
fi

pvesm set local --content iso,vztmpl,backup,snippets
mkdir -p /var/lib/vz/snippets
cp "$SNIPPET_SRC" /var/lib/vz/snippets/k3s-vendor.yaml

mkdir -p "$IMAGE_DIR"
[ -f "$IMAGE_PATH" ] || wget -O "$IMAGE_PATH" "$IMAGE_URL"

qm create "$VMID" --name ubuntu-2404-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set "$VMID" --scsi0 "$STORAGE:0,import-from=$IMAGE_PATH"
qm set "$VMID" --ide2 "$STORAGE:cloudinit"
qm set "$VMID" --boot order=scsi0
qm set "$VMID" --serial0 socket --vga serial0
qm set "$VMID" --agent enabled=1
qm set "$VMID" --cicustom vendor=local:snippets/k3s-vendor.yaml
qm set "$VMID" --ipconfig0 ip=dhcp
qm template "$VMID"

echo "Template $VMID ready"
qm config "$VMID"
