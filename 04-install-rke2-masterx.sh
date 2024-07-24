#!/bin/bash

source ./params.sh
source ./utils.sh
source ./load-tf-output.sh

LogStarted "Installing other RKE2 nodes.."

echo
Log "\__Creating cluster masterx config.yaml.."

cat << EOF >./local/masterx-config.yaml
server: https://${NODE_PRIVATE_IP[1]}:9345
token: $RKE2_TOKEN
EOF

function rke2joinmasterx
{
  NODENUM=$1

  Log "function rke2joinmasterx: for node $NODENUM"

  ANODEIP=${NODE_PUBLIC_IP[$NODENUM]}
  ANODENAME=${NODE_NAME[$NODENUM]}
  APRIVATEIP=${NODE_PRIVATE_IP[$NODENUM]}

  Log "Joining RKE2 node (HOST: $ANODENAME IP: $ANODEIP $APRIVATEIP).."

  scp $SSH_OPTS ./local/masterx-config.yaml ${SSH_USERNAME}@${ANODEIP}:~/config.yaml
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo mkdir -p /etc/rancher/rke2"
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo cp config.yaml /etc/rancher/rke2/"

  Log "\__Installing RKE2 (master$NODENUM).."
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo bash -c 'curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh - 2>&1 > /root/rke2-install.log 2>&1'"
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo systemctl enable rke2-server.service"
  Log "\__starting rke2-server.service.."
  ssh $SSH_OPTS ${SSH_USERNAME}@${ANODEIP} "sudo systemctl start rke2-server.service"
}



function rke2joinmasterxwait
{
  NODENUM=$1

  Log "function rke2joinmasterxwait: for node $NODENUM"

  # wait until cluster nodes read
  Log "\__Waiting for new RKE2 cluster node to be Ready.."
  READY=false
  while ! $READY
  do
    NRC=`kubectl --kubeconfig=./local/admin.conf get nodes 2>&1 | egrep 'NotReady|connection refused|no such host' | wc -l`
    if [ $NRC -eq 0 ]; then
      echo -n 0
      echo
      Log "-\__RKE2 cluster nodes are Ready:"
      kubectl --kubeconfig=./local/admin.conf get nodes --show-labels=true
      READY=true
    else
      echo -n ${NRC}.
      sleep 10
    fi
  done

  # wait until cluster fully up
  Log "\__Waiting for RKE2 cluster to be fully initialised.."
  sleep 30
  READY=false
  while ! $READY
  do
    NRC=`kubectl --kubeconfig=./local/admin.conf get pods --all-namespaces 2>&1 | egrep -v 'Running|Completed|NAMESPACE' | wc -l`
    if [ $NRC -eq 0 ]; then
      echo -n 0
      echo
      Log " \__RKE2 new cluster node is now initialised."
      READY=true
    else
      echo -n ${NRC}.
      sleep 10
    fi
  done
}


# Join node 2
rke2joinmasterx 2
LogElapsedDuration

rke2joinmasterxwait 2
LogElapsedDuration

# Join node 3
rke2joinmasterx 3
LogElapsedDuration

rke2joinmasterxwait 3
LogElapsedDuration


LogCompleted "Done."

# tidy up
exit 0
