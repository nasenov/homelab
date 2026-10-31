#!/usr/bin/env -S just --justfile

set minimum-version := '1.55.0'

set default-list
set default-script
set lazy
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# Kube Recipes
[group('Kube')]
mod kube "kubernetes"

# Talos Recipes
[group('Talos')]
mod talos "opentofu/talos"

# OpenTofu Recipes
[group('OpenTofu')]
mod tofu "opentofu"

[doc('Bootstrap workstation')]
[script]
bootstrap-workstation:
    just tofu init
    just tofu sync-tfvars
    just talos talosconfig
    just talos kubeconfig
