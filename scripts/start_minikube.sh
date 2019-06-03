#!/bin/bash

sudo minikube start --vm-driver=none
sudo chown -R $USER $HOME/.kube $HOME/.minikube
helm init
