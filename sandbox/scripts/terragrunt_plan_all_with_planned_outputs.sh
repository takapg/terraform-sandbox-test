#!/bin/bash

set -eux

usage() {
  cat << EOS >&2
terragrunt_plan_all_with_planned_outputs.sh

USAGE:
  ./terragrunt_plan_all_with_planned_outputs.sh [options] <working-dir>

ARGS:
  working-dir  Set the directory where this script should execute.

OPTIONS:
  --skip-switch-back  Skip switch back of Terraform backend from local to remote to save time.
                      It is recommended to specify this in CI where only "plan" is executed.
                      Do not specify in environments where "apply" is executed,
                      because it will update the local tfstate.
EOS
}

invalid() {
  usage 1>&2
  echo "$@" 1>&2
  exit 1
}

skip_switch_back=false

args=()
while (( $# > 0 ))
do
  case $1 in
    --skip-switch-back)
      skip_switch_back=true
      ;;
    -*)
      invalid "Illegal option -- '$(echo $1 | sed 's/^-*//')'."
      exit 1
      ;;
    *)
      args=("${args[@]}" "$1")
      ;;
  esac
  shift
done

expected_argument_count=1

if [[ "${#args[@]}" -lt ${expected_argument_count} ]]; then
  invalid "Too few arguments."
  exit 1
elif [ "${#args[@]}" -gt ${expected_argument_count} ]; then
  invalid "Too many arguments."
  exit 1
fi

get_nth () {
  local n=$1
  shift
  eval echo \$${n}
}

echo ${skip_switch_back}
working_dir=$(get_nth 1 "${args[@]}")

root_terragrunt_file_path="$(dirname $0)/../terragrunt.hcl"
backup_root_terragrunt_file_path="${root_terragrunt_file_path}_backup"
backend_override_file_path='tmp_backend_override.tf'
tfstate_file_path='tmp_terraform.tfstate'
tfplan_file_path='tmp_plan.tfplan'

cp ${root_terragrunt_file_path} ${backup_root_terragrunt_file_path}

if [ ! "$(hcledit block list --file ${root_terragrunt_file_path} | grep 'terraform' )" ]; then
  cat << EOF >> ${root_terragrunt_file_path}
terraform {
}
EOF
fi

hcledit --file ${root_terragrunt_file_path} --update block append terraform after_hook.tmp_after_plan
hcledit --file ${root_terragrunt_file_path} --update attribute append terraform.after_hook.tmp_after_plan.commands '["plan"]'
hcledit --file ${root_terragrunt_file_path} --update attribute append terraform.after_hook.tmp_after_plan.execute '["${get_parent_terragrunt_dir()}/scripts/override_backend_to_local_and_set_planned_outputs.sh"]'
hcledit --file ${root_terragrunt_file_path} --update attribute append terraform.after_hook.tmp_after_plan.run_on_error 'false'

terragrunt run-all plan -out ${tfplan_file_path} --terragrunt-working-dir ${working_dir}

mv ${backup_root_terragrunt_file_path} ${root_terragrunt_file_path}
find ${working_dir} -name ${backend_override_file_path} | xargs rm

if ! ${skip_switch_back}; then
  terragrunt run-all init -reconfigure --terragrunt-working-dir ${working_dir}
fi
