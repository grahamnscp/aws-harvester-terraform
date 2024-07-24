#!/bin/bash

source ./params.sh
source ./utils.sh
source ./load-tf-output.sh


# Install to master1 node
NODEIP=${NODE_PUBLIC_IP[1]}
NODENAME=${NODE_NAME[1]}
PRIVATEIP=${NODE_PRIVATE_IP[1]}

export KUBECONFIG=./local/admin.conf


LogStarted "Installing Rancher to ($NODENAME).."

Log "\__Rancher system-upgrade-controller (${RANCHERSYSTEMUPGRADECONTROLLER}).."
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/${RANCHERSYSTEMUPGRADECONTROLLER}/system-upgrade-controller.yaml

Log "\__pausing............20"
sleep 20


Log "\__Add helm repo rancher-latest.."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

Log "\__helm install rancher-latest/rancher (rancherImageTag=${RANCHERIMAGETAG}).."
helm install rancher rancher-latest/rancher --namespace cattle-system --create-namespace \
        --set tls=external \
        --set rancherImagePullPolicy=IfNotPresent \
        --set rancherImage=rancher/rancher \
        --set rancherImageTag=${RANCHERIMAGETAG} \
        --set noDefaultAdmin=false \
        --set features="multi-cluster-management=false\,multi-cluster-management-agent=false" \
        --set useBundledSystemChart=true \
        --set bootstrapPassword=${BOOTSTRAPADMINPWD}

# wait until cluster fully up
Log "\__Waiting for Rancher to be fully initialised.."
sleep 30
READY=false
while ! $READY
do
  NRC=`kubectl --kubeconfig=./local/admin.conf get pods --all-namespaces 2>&1 | egrep -v 'Running|Completed|NAMESPACE' | wc -l`
  if [ $NRC -eq 0 ]; then
    echo -n 0
    echo
    Log " \__Rancher is now initialised."
    READY=true
  else
    echo -n ${NRC}.
    sleep 10
  fi
done


Log "\__git clone rancher/charts (-b ${RANCHERCHARTSBRANCH}).."
git clone https://github.com/rancher/charts -b ${RANCHERCHARTSBRANCH} ./local/rancher/

Log "\__helm install rancher-monitoring-crd (${RANCHERMONITORINGCRD}).."
helm install rancher-monitoring-crd ./local/rancher/charts/rancher-monitoring-crd/${RANCHERMONITORINGCRD}/

Log "\__pausing............20"
sleep 20

LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0
