#!/bin/bash

set -eux

backend_override_file_path='tmp_backend_override.tf'
tfstate_file_path='tmp_terraform.tfstate'
tfplan_file_path='tmp_plan.tfplan'

cat << EOF > ${backend_override_file_path}
terraform {
  backend "local" {
    path = "${tfstate_file_path}"
  }
}
EOF

terraform init -reconfigure

cat << EOF > ${tfstate_file_path}
{
  "version": 4,
  "outputs": {
  }
}
EOF

outputs=$(terraform show -json ${tfplan_file_path} | jq '.planned_values.outputs')

if [ "${outputs}" != 'null' ]; then
  filled_in_missing_values_outputs=$(echo ${outputs} | jq 'map_values(if .value then . else . |= { "value": "known-after-apply", "type": "string" } end)')
  cat ${tfstate_file_path} | jq ".outputs |= ${filled_in_missing_values_outputs}" > "${tfstate_file_path}_tmp"
  mv "${tfstate_file_path}_tmp" ${tfstate_file_path}
fi
