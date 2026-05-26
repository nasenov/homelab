set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    just -l kube

[doc('Prune pods in Failed, Pending, or Succeeded state')]
[script]
prune-pods:
    for phase in Failed Pending Succeeded; do
        kubectl delete pods --all-namespaces --field-selector status.phase="$phase" --ignore-not-found=true
    done

[doc('Snapshot volsync PVCs')]
[script]
snapshot:
    kubectl get replicationsources --all-namespaces --no-headers | while read -r ns name _; do
        kubectl --namespace "$ns" patch replicationsources "$name" --type merge -p "{\"spec\":{\"trigger\":{\"manual\":\"$(date +%s)\"}}}"
    done

[arg('resource', pattern='hr|ks|gitrepo|ocirepo|es')]
[doc('Sync a resource')]
[script]
sync resource:
    kubectl get {{ resource }} --all-namespaces --no-headers | while read -r ns name _; do
        kubectl --namespace "$ns" annotate --field-manager flux-client-side-apply --overwrite {{ resource }} "$name" \
            "force-sync=$(date +%s)" \
            "reconcile.fluxcd.io/requestedAt=$(date +%s)" \
            "reconcile.fluxcd.io/forceAt=$(date +%s)"
    done
