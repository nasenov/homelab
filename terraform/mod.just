set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    just -l terraform

[doc('Initialize Terraform directories')]
[script]
init:
    for tfdir in $(find . -mindepth 1 -maxdepth 1 -type d); do
        terraform -chdir="$tfdir" init -upgrade
    done

[doc('Sync terraform tfvars')]
[script]
sync-tfvars:
    bws secret get 3218d99d-71fa-4c83-9e61-74978941d19f | jq --raw-output '.value' > ./cloudflare/terraform.tfvars
