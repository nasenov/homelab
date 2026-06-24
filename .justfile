#!/usr/bin/env -S just --justfile

set default-script
set lazy
set quiet
set shell := ['bash', '-euo', 'pipefail', '-c']

# Kube Recipes
[group: 'Kube']
mod kube "kubernetes"

# Talos Recipes
[group: 'Talos']
mod talos "terraform/talos"

# Terraform Recipes
[group: 'Terraform']
mod terraform "terraform"

[private]
default:
    just -l

[doc('Bootstrap workstation')]
[script]
bootstrap-workstation:
    just terraform init
    just terraform sync-tfvars
    just talos fetch-talosconfig
    just talos fetch-kubeconfig
