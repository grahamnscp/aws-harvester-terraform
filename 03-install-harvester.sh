#!/bin/bash

source ./params.sh
source ./utils.sh
source ./load-tf-output.sh


# Install to master1 node
NODEIP=${NODE_PUBLIC_IP[1]}
NODENAME=${NODE_NAME[1]}
PRIVATEIP=${NODE_PRIVATE_IP[1]}

export KUBECONFIG=./local/admin.conf


LogStarted "Installing Harvester to ($NODENAME).."

Log "\__Install harvester-bootstrap-repo (into cattle-system).."
kubectl apply -f harvester-bootstrap-repo/harvester-bootstrap-repo-deployment.yaml
kubectl apply -f harvester-bootstrap-repo/harvester-bootstrap-repo-service.yaml
kubectl apply -f harvester-bootstrap-repo/harvester-bootstrap-repo-clusterrepo.yaml

Log "\__create namespace harvester-system.."
kubectl create ns harvester-system

Log "\__git clone harvester (-b ${HARVESTERREPOBRANCH}).."
git clone https://github.com/harvester/harvester.git -b ${HARVESTERREPOBRANCH} ./local/harvester/

Log "\__helm install harvester-crd.."
helm install harvester-crd ./local/harvester/deploy/charts/harvester-crd --namespace harvester-system

Log "\__pausing............20"
sleep 20


Log "\__helm install harvester.."
helm install harvester ./local/harvester/deploy/charts/harvester --namespace harvester-system \
        --set harvester-node-disk-manager.enabled=true \
        --set "harvester-node-disk-manager.labelFilter={COS_*,HARV_*}" \
        --set harvester-network-controller.enabled=true \
        --set harvester-network-controller.vipEnabled=true \
        --set harvester-load-balancer.enabled=true \
        --set kube-vip.enabled=true \
        --set kube-vip-cloud-provider.enabled=true \
        --set longhorn.enabled=true \
        --set longhorn.defaultSettings.defaultDataPath=/var/lib/harvester/defaultdisk \
        --set longhorn.defaultSettings.taintToleration=kubevirt.io/drain:NoSchedule \
        --set rancherEmbedded=true \
        --set service.vip.enabled=false

Log "\__pausing............300"
sleep 300


Log "\__load harvester addons.."
cp ./addons/rancher-monitoring.yaml.template ./local/rancher-monitoring.yaml
sed -i '' "s/MASTER1PRIVATEIP/$PRIVATEIP/g" ./local/rancher-monitoring.yaml
kubectl create namespace cattle-monitoring-system
kubectl apply -f ./local/rancher-monitoring.yaml

cp ./addons/vm-import-controller.yaml.template ./local/vm-import-controller.yaml
kubectl apply -f ./local/vm-import-controller.yaml

Log "\__pausing............90"
sleep 90


echo 
echo 
echo "Access cluster at:"
echo open https://$NODENAME
echo 

LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0
