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

[doc('Restore a PVC from volsync')]
[script]
restore ns app previous='0':
    flux --namespace {{ ns }} suspend kustomization {{ app }}
    flux --namespace {{ ns }} suspend helmrelease {{ app }}
    kubectl --namespace {{ ns }} get deploy,sts --selector app.kubernetes.io/name={{ app }} --output name \
        | xargs -r -I{} kubectl --namespace {{ ns }} scale {} --replicas=0
    kubectl --namespace {{ ns }} wait pod --for=delete --selector="app.kubernetes.io/name={{ app }}" --timeout=5m
    kubectl --namespace {{ ns }} get replicationdestination {{ app }}-dst --output json \
        | jq 'del(.status)
            | .metadata = {name: "{{ app }}-manual", namespace: .metadata.namespace}
            | .spec.restic.copyMethod = "Direct"
            | .spec.restic.destinationPVC = "{{ app }}"
            | .spec.restic.previous = {{ previous }}' \
        | kubectl apply --server-side --filename -
    kubectl --namespace {{ ns }} wait job/volsync-dst-{{ app }}-manual --for=create --timeout=120s
    kubectl --namespace {{ ns }} wait job/volsync-dst-{{ app }}-manual --for=condition=complete --timeout=120m
    kubectl --namespace {{ ns }} delete replicationdestination {{ app }}-manual
    flux --namespace {{ ns }} resume kustomization {{ app }}
    flux --namespace {{ ns }} resume helmrelease {{ app }}
    flux --namespace {{ ns }} reconcile helmrelease {{ app }} --force
    kubectl --namespace {{ ns }} wait pod --for=condition=ready --selector="app.kubernetes.io/name={{ app }}" --timeout=5m

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
