#!/bin/bash

source ./params.sh
source ./utils.sh
source ./load-tf-output.sh


# master1 instance
NODEIP=${NODE_PUBLIC_IP[1]}
NODENAME=${NODE_NAME[1]}
PRIVATEIP=${NODE_PRIVATE_IP[1]}


LogStarted "Installing initial RKE2 master1 (HOST: $NODENAME IP: $NODEIP $PRIVATEIP).."

#Log "\__Set extra NIC state down for RKE2 install.."
#ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo ifdown eth1"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo ifdown eth2 -o force"

Log "\__Creating cluster config.yaml.."
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo mkdir -p /etc/rancher/rke2"
cat << EOF >./local/master1-config.yaml
token: $RKE2_TOKEN
tls-san:
- $NODENAME
- $NODEIP
- harvester.$DOMAINNAME
disable:
- rke2-snapshot-controller
- rke2-snapshot-controller-crd
- rke2-snapshot-validation-webhook
node-label:
- harvesterhci.io/managed=true
cni:
- multus
- canal
EOF
scp $SSH_OPTS ./local/master1-config.yaml ${SSH_USERNAME}@${NODEIP}:~/config.yaml
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo cp config.yaml /etc/rancher/rke2/"


Log "\__Installing RKE2 (master1).."
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo bash -c 'curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh - 2>&1 > /root/rke2-install.log 2>&1'"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo systemctl enable rke2-server.service"
Log "\__starting rke2-server.service.."
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo systemctl start rke2-server.service"


Log "\__Waiting for kubeconfig file to be created.."
WAIT=30
UP=false
while ! $UP
do
  ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo test -e /etc/rancher/rke2/rke2.yaml && exit 10 </dev/null"
  if [ $? -eq 10 ]; then
    echo Cluster is now configured..
    UP=true
  else
    sleep $WAIT
  fi
done

Log "\__Downloading kube admin.conf locally.."
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo cp /etc/rancher/rke2/rke2.yaml ~/admin.conf"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo chown ${SSH_USERNAME}:users ~/admin.conf"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo chmod 600 ~/admin.conf"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "echo export KUBECONFIG=~/admin.conf >> ~/.bashrc"

# Local admin.conf
mkdir -p ./local
if [ -f ./local/admin.conf ] ; then rm ./local/admin.conf ; fi
scp $SSH_OPTS ${SSH_USERNAME}@${NODEIP}:~/admin.conf ./local/
sed -i '' "s/127.0.0.1/$NODENAME/g" ./local/admin.conf
chmod 600 ./local/admin.conf

Log "\__adding link to kubectl bin.."
KDIR=`ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "ls /var/lib/rancher/rke2/data/"`
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "cd /usr/local/bin ; sudo ln -s /var/lib/rancher/rke2/data/$KDIR/bin/kubectl kubectl"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo bash -c 'echo export KUBECONFIG=/etc/rancher/rke2/rke2.yaml >> /root/.bashrc'"
ssh $SSH_OPTS ${SSH_USERNAME}@${NODEIP} "sudo bash -c 'echo alias k=kubectl >> /root/.bashrc'"

LogElapsedDuration

# wait until cluster nodes read
Log "\__Waiting for single node RKE2 cluster to be Ready.."
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
    Log " \__RKE2 cluster is now initialised."
    READY=true
  else
    echo -n ${NRC}.
    sleep 10
  fi
done

LogElapsedDuration
LogCompleted "Done."

# tidy up
exit 0
