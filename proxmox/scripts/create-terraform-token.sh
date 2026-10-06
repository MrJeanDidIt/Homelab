#!/usr/bin/env bash
set -euo pipefail

ROLE="TerraformProv"
PVE_USER="terraform@pve"
TOKEN="provider"
PRIVS="Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"

PVE_MAJOR="$(pveversion | awk -F'[/.]' '{print $2}')"
if [ "$PVE_MAJOR" -ge 9 ]; then
  PRIVS="$PRIVS VM.GuestAgent.Audit"
fi

pveum role add "$ROLE" -privs "$PRIVS" 2>/dev/null || pveum role modify "$ROLE" -privs "$PRIVS"
pveum user add "$PVE_USER" 2>/dev/null || true
pveum aclmod / -user "$PVE_USER" -role "$ROLE"
pveum user token remove "$PVE_USER" "$TOKEN" 2>/dev/null || true
pveum user token add "$PVE_USER" "$TOKEN" --privsep=0

echo "Put this in terraform.tfvars: pm_api_token = \"$PVE_USER!$TOKEN=<value shown above>\""
