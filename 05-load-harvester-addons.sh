#!/bin/bash

source ./params.sh
source ./utils.sh
source ./load-tf-output.sh


# Install to master1 node
NODEIP=${NODE_PUBLIC_IP[1]}
NODENAME=${NODE_NAME[1]}
PRIVATEIP=${NODE_PRIVATE_IP[1]}

export KUBECONFIG=./local/admin.conf


LogStarted "Installing Harvester Addons to ($NODENAME).."

Log "\__loading rancher-monitoring addon.."
cp ./addons/rancher-monitoring.yaml.template ./local/rancher-monitoring.yaml
sed -i '' "s/MASTER1PRIVATEIP/$PRIVATEIP/g" ./local/rancher-monitoring.yaml
kubectl create namespace cattle-monitoring-system
kubectl apply -f ./local/rancher-monitoring.yaml

Log "\__pausing............120"
sleep 120


Log "\__loading vm-import-controller addon.."
cp ./addons/vm-import-controller.yaml.template ./local/vm-import-controller.yaml
kubectl apply -f ./local/vm-import-controller.yaml

Log "\__pausing............120"
sleep 120

LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0
