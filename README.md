<div align="center">

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=blue)](https://discord.gg/home-operations)&nbsp;&nbsp;
[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Flux](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fflux_version&style=for-the-badge&logo=flux&logoColor=white&color=blue&label=%20)](https://fluxcd.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/nasenov/homelab/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/nasenov/homelab/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Power-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_power_usage&style=flat-square&label=Power)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Alerts](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.nasenov.dev%2Fcluster_alert_count&style=flat-square&label=Alerts)](https://github.com/kashalls/kromgo)

</div>

---

## <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f4a1/512.gif" alt="💡" width="20" height="20"> Overview

Welcome to my home infrastructure and Kubernetes cluster repository! This project embraces Infrastructure as Code (IaC) and GitOps principles, leveraging [Kubernetes](https://github.com/kubernetes/kubernetes), [Flux](https://github.com/fluxcd/flux2), [Terraform](https://www.terraform.io/), [Renovate](https://github.com/renovatebot/renovate), and [GitHub Actions](https://github.com/features/actions) to maintain a fully automated, declarative homelab environment.

---

## <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f331/512.gif" alt="🌱" width="20" height="20"> Kubernetes

My semi-hyperconverged cluster runs [Talos Linux](https://github.com/siderolabs/talos)-an immutable, minimal Linux distribution purpose-built for Kubernetes-on three bare-metal machines. Storage is handled by [Rook](https://github.com/rook/rook), providing persistent block, object, and file storage directly within the cluster, complemented by a dedicated NAS for media files. The entire cluster is architected for complete reproducibility: I can tear it down and rebuild from scratch without losing any data.

### Core Components

- [cert-manager](https://github.com/cert-manager/cert-manager): Creates TLS certificates for services in my cluster.
- [cilium](https://github.com/cilium/cilium): High-performance container networking powered by [eBPF](https://ebpf.io).
- [cloudflared](https://github.com/cloudflare/cloudflared): Secure tunnel providing Cloudflare-protected access to cluster services.
- [envoy-gateway](https://github.com/envoyproxy/gateway): Modern ingress controller for cluster traffic management.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automated DNS record synchronization for ingress resources.
- [external-secrets](https://github.com/external-secrets/external-secrets): Kubernetes secrets management integrated with [Bitwarden](https://bitwarden.com/).
- [rook](https://github.com/rook/rook): Cloud-native distributed storage orchestrator for persistent storage.
- [spegel](https://github.com/spegel-org/spegel): Stateless cluster local OCI registry mirror.
- [volsync](https://github.com/backube/volsync): Backup and recovery of persistent volume claims.

### GitOps

[Flux](https://github.com/fluxcd/flux2) continuously monitors the [kubernetes](./kubernetes) folder and reconciles my cluster state with whatever is defined in this Git repository-Git is the single source of truth.

Here's how it works: Flux recursively scans the [kubernetes/apps](./kubernetes/apps) directory, discovering the top-level `kustomization.yaml` in each subdirectory. These files typically define a namespace and one or more Flux `Kustomization` resources (`ks.yaml`). Each Flux `Kustomization` then manages a `HelmRelease` or other Kubernetes resources for that application.

Meanwhile, [Renovate](https://github.com/renovatebot/renovate) continuously scans the **entire** repository for dependency updates, automatically opening pull requests when new versions are available. Once merged, Flux picks up the changes and updates the cluster automatically.

### Directories

This Git repository contains the following directories under [Kubernetes](./kubernetes/).

```sh
📁 kubernetes
├── 📁 apps       # applications
├── 📁 components # re-useable kustomize components
└── 📁 cluster    # flux system configuration
```

### Cluster layout

Here's how Flux orchestrates application deployments with dependencies. Most applications are deployed as `HelmRelease` resources that depend on other `HelmRelease`'s, while some `Kustomization`'s depend on other `Kustomization`'s. Occasionally, an application may have dependencies on both types. The diagram below illustrates this: `actual` won't deploy or upgrade until `rook-ceph-cluster` is successfully installed and healthy.

<details>
  <summary>Click to see a high-level architecture diagram</summary>

```mermaid
graph LR
    classDef kustom fill:#43A047,stroke:#2E7D32,stroke-width:3px,color:#fff,font-weight:bold,rx:10,ry:10
    classDef helm fill:#1976D2,stroke:#0D47A1,stroke-width:3px,color:#fff,font-weight:bold,rx:10,ry:10

    A["📦 Kustomization<br/>rook-ceph"]:::kustom
    B["📦 Kustomization<br/>rook-ceph-cluster"]:::kustom
    C["🎯 HelmRelease<br/>rook-ceph"]:::helm
    D["🎯 HelmRelease<br/>rook-ceph-cluster"]:::helm
    E["📦 Kustomization<br/>actual"]:::kustom
    F["🎯 HelmRelease<br/>actual"]:::helm

    A -->|Creates| C
    B -->|Creates| D
    B -.->|Depends on| A
    E -->|Creates| F
    E -.->|Depends on| B
```
</details>

---

## <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f636_200d_1f32b_fe0f/512.gif" alt="😶" width="20" height="20"> Cloud Dependencies

While most of my infrastructure and workloads are self-hosted I do rely upon the cloud for certain key parts of my setup.

| Service                                      | Use                                                           | Cost          |
|----------------------------------------------|---------------------------------------------------------------|---------------|
| [Bitwarden](https://bitwarden.com/)          | Secrets with [External Secrets](https://external-secrets.io/) | Free          |
| [Cloudflare](https://cloudflare.com/)        | Domain, S3 and Tunnel                                         | ~$12/yr       |
| [Discord](https://discord.com/)              | Alerts and Notifications                                      | Free          |
| [Github](https://github.com/)                | Github Actions                                                | Free          |
| [Let's Encrypt](https://letsencrypt.org/)    | TLS certificates                                              | Free          |
|                                              |                                                               | Total: ~$1/mo |

---

## <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f30e/512.gif" alt="🌎" width="20" height="20"> DNS

I run two instances of [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) to handle DNS automation:

- **Private DNS**: Syncs records to my `Pi-hole`
- **Public DNS**: Syncs records to `Cloudflare`

This is achieved by defining routes with two specific gateways: `internal` for private DNS and `external` for public DNS. Each ExternalDNS instance watches for routes using its assigned gateway and syncs the appropriate DNS records to the corresponding platform.

---

## <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/2699_fe0f/512.gif" alt="⚙" width="20" height="20"> Hardware

| Device                | Num | OS Disk Size | Data Disk Size                                   | RAM   | OS      | Function         |
|-----------------------|-----|--------------|--------------------------------------------------|-------|---------|------------------|
| Lenovo m910x i5-7500  | 3   | 256GB NVMe   | 500GB SSD (local) / 1TB NVMe (rook-ceph)         | 16GB  | Talos   | Kubernetes       |
| Aoostar WTR PRO 5825U | 1   | 256GB NVMe   | 2x2TB SSD                                        | 16GB  | TrueNAS | NAS              |
| TP-Link Archer AX53   | 1   | -            | -                                                | -     | -       | Router           |
