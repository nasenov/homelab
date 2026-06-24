set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    just -l talos

[confirm('Bootstrap Kubernetes cluster [y|N] ?')]
[doc('Bootstrap Kubernetes cluster')]
bootstrap: apply fetch-talosconfig fetch-kubeconfig apps

[doc('Fetch talosconfig')]
fetch-talosconfig:
    umask 077
    terraform output --raw talosconfig > {{ justfile_directory() }}/talosconfig

[doc('Fetch kubeconfig')]
fetch-kubeconfig:
    talosctl kubeconfig --nodes $(talosctl config info -o json | jq '.endpoints.[0]') --force {{ justfile_directory() }}

[confirm('Destroy Kubernetes cluster [y|N] ?')]
[doc('Destroy Kubernetes cluster')]
destroy:
    talosctl reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe u-openebs --graceful=false --reboot
    terraform state rm $(terraform state list)

[private]
apply:
    terraform apply

[private]
apps:
    kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -
    kubectl create secret generic bitwarden-access-token --namespace external-secrets \
    --from-literal=token="$(bws secret get baf8e9bc-d0a7-447a-93c7-7d93b4d20597 | jq --raw-output '.value')" \
    --dry-run=client -o yaml | kubectl apply -f -
    helmfile --file {{ justfile_directory() }}/kubernetes/bootstrap/helmfile/crds.yaml template --quiet | yq ea -r -e 'select(.kind == "CustomResourceDefinition")' | kubectl apply --server-side -f -
    helmfile --file {{ justfile_directory() }}/kubernetes/bootstrap/helmfile/apps.yaml sync --hide-notes
