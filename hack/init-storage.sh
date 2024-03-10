#!/bin/bash
scp admin@192.168.1.100:/etc/rancher/k3s/k3s.yaml ~/.kube/config-storage

chmod 0600 ~/.kube/config-storage

kubectl --kubeconfig ~/.kube/config-storage config set-cluster default --server=https://192.168.1.100:6443

