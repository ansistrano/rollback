#!/usr/bin/env bash
set -euo pipefail

mode="${1:-integration}"
shift || true

repo_dir="/workspace/rollback"
inventory_file="/tmp/ansistrano-inventory"
roles_path="/etc/ansible/roles"

mkdir -p "${roles_path}"
ln -sfn "${repo_dir}" "${roles_path}/local-ansistrano"
printf 'localhost ansible_connection=local\n' > "${inventory_file}"

ANSIBLE_ROLES_PATH="${roles_path}" ansible-galaxy role install -f -p "${roles_path}" ansistrano.deploy

cd "${repo_dir}/test"

case "${mode}" in
  syntax)
    exec env ANSIBLE_ROLES_PATH="${roles_path}" ansible-playbook -i "${inventory_file}" --syntax-check test.yml "$@"
    ;;
  integration)
    env ANSIBLE_ROLES_PATH="${roles_path}" ansible-playbook -i "${inventory_file}" --connection=local --become -e update_cache=1 -v deploy.yml "$@"
    exec env ANSIBLE_ROLES_PATH="${roles_path}" ansible-playbook -i "${inventory_file}" --connection=local --become -e update_cache=1 -v test.yml "$@"
    ;;
  *)
    echo "Usage: run-ansistrano-tests [syntax|integration] [extra ansible-playbook args...]" >&2
    exit 2
    ;;
esac
