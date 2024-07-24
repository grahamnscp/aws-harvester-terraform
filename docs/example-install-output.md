# Example Install Output

## Infra deployment via Terraform
```
$ cd tf
$ terraform apply -auto-approve

…

Apply complete! Resources: 24 added, 0 changed, 0 destroyed.

Outputs:

aws-region = "us-east-1"
domainname = "test.suselabs.net"
instance-name = [
  [
    "lab-master1.test.suselabs.net",
    "lab-master2.test.suselabs.net",
    "lab-master3.test.suselabs.net",
  ],
]
instance-private-ip = [
  [
    "10.0.1.77",
    "10.0.1.221",
    "10.0.1.51",
  ],
]
instance-private-nic2-ip = [
  [
    "10.0.2.82",
    "10.0.2.95",
    "10.0.2.142",
  ],
]
instance-private-nic3-ip = [
  "10.0.1.160",
]
instance-public-eip = [
  [
    "54.83.20.247",
    "3.219.127.55",
    "54.172.172.223",
  ],
]
instance-public-ip = [
  [
    "34.200.232.214",
    "34.201.55.13",
    "44.199.229.86",
  ],
]

$ cd ..
```

## Clean local directory from any previous run
```
$ ./00-clean-local-dir
```

## RKE2 master1 install
```
$ ./01-install-rke2-master1.sh
[2024-07-23 15:31:26 INFO] Collecting terraform output values..
lab-master1.test.suselabs.net 54.83.20.247 10.0.1.77 10.0.2.82 10.0.1.160
lab-master2.test.suselabs.net 3.219.127.55 10.0.1.221 10.0.2.95
lab-master3.test.suselabs.net 54.172.172.223 10.0.1.51 10.0.2.142
[2024-07-23 15:31:39 STARTED] Installing initial RKE2 master1 (HOST: lab-master1.test.suselabs.net IP: 54.83.20.247 10.0.1.77)..
Warning: Permanently added '54.83.20.247' (ED25519) to the list of known hosts.
eth2            device-exists
[2024-07-23 15:31:49 INFO] \__Creating cluster config.yaml..
master1-config.yaml                                                                                                                        100%  274     3.4KB/s   00:00
[2024-07-23 15:31:53 INFO] \__Installing RKE2 (master1)..
Created symlink /etc/systemd/system/multi-user.target.wants/rke2-server.service → /usr/local/lib/systemd/system/rke2-server.service.
[2024-07-23 15:31:57 INFO] \__starting rke2-server.service..
[2024-07-23 15:32:44 INFO] \__Waiting for kubeconfig file to be created..
Cluster is now configured..
[2024-07-23 15:32:45 INFO] \__Downloading kube admin.conf locally..
admin.conf                                                                                                                                 100% 2969    17.9KB/s   00:00
[2024-07-23 15:32:51 INFO] \__adding link to kubectl bin..
[2024-07-23 15:32:55 DURATION] 1 minutes and 29 seconds elapsed.
[2024-07-23 15:32:55 INFO] \__Waiting for single node RKE2 cluster to be Ready..
1.1.1.0
[2024-07-23 15:33:30 INFO] -\__RKE2 cluster nodes are Ready:
NAME           STATUS   ROLES                       AGE   VERSION           LABELS
ip-10-0-1-77   Ready    control-plane,etcd,master   53s   v1.27.10+rke2r1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=rke2,beta.kubernetes.io/os=linux,harvesterhci.io/managed=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-10-0-1-77,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node-role.kubernetes.io/etcd=true,node-role.kubernetes.io/master=true,node.kubernetes.io/instance-type=rke2
[2024-07-23 15:33:31 INFO] \__Waiting for RKE2 cluster to be fully initialised..
0
[2024-07-23 15:34:01 INFO]  \__RKE2 cluster is now initialised.
[2024-07-23 15:34:01 DURATION] 2 minutes and 35 seconds elapsed.
[2024-07-23 15:34:01 COMPLETED] Done.
```

## Rancher install master1
```
$ ./02-install-rancher.sh
[2024-07-23 15:34:13 INFO] Collecting terraform output values..
lab-master1.test.suselabs.net 54.83.20.247 10.0.1.77 10.0.2.82 10.0.1.160
lab-master2.test.suselabs.net 3.219.127.55 10.0.1.221 10.0.2.95
lab-master3.test.suselabs.net 54.172.172.223 10.0.1.51 10.0.2.142
[2024-07-23 15:34:26 STARTED] Installing Rancher to (lab-master1.test.suselabs.net)..
[2024-07-23 15:34:26 INFO] \__Rancher system-upgrade-controller (v0.13.1)..
namespace/system-upgrade created
serviceaccount/system-upgrade created
clusterrolebinding.rbac.authorization.k8s.io/system-upgrade created
configmap/default-controller-env created
deployment.apps/system-upgrade-controller created
[2024-07-23 15:34:30 INFO] \__pausing............20
[2024-07-23 15:34:50 INFO] \__Add helm repo rancher-latest..
"rancher-latest" already exists with the same configuration, skipping
[2024-07-23 15:34:50 INFO] \__helm install rancher-latest/rancher (rancherImageTag=v2.8.2)..
NAME: rancher
LAST DEPLOYED: Tue Jul 23 15:34:51 2024
NAMESPACE: cattle-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Rancher Server has been installed.

NOTE: Rancher may take several minutes to fully initialize. Please standby while Certificates are being issued, Containers are started and the Ingress rule comes up.

Check out our docs at https://rancher.com/docs/

If you provided your own bootstrap password during installation, browse to https:// to get started.

If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:

echo https:///dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

To get just the bootstrap password on its own, run:

kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'

Happy Containering!
[2024-07-23 15:34:55 INFO] \__Waiting for Rancher to be fully initialised..
3.3.0
[2024-07-23 15:35:49 INFO]  \__Rancher is now initialised.
[2024-07-23 15:35:49 INFO] \__Git clone rancher/charts (-b release-v2.8)..
Cloning into './local/rancher'...
remote: Enumerating objects: 97351, done.
remote: Counting objects: 100% (3569/3569), done.
remote: Compressing objects: 100% (1672/1672), done.
remote: Total 97351 (delta 2048), reused 3052 (delta 1697), pack-reused 93782
Receiving objects: 100% (97351/97351), 272.03 MiB | 8.66 MiB/s, done.
Resolving deltas: 100% (54220/54220), done.
Updating files: 100% (30114/30114), done.
[2024-07-23 15:36:37 INFO] \__helm install rancher-monitoring-crd (103.1.0+up45.31.1)..
NAME: rancher-monitoring-crd
LAST DEPLOYED: Tue Jul 23 15:36:38 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
[2024-07-23 15:38:02 INFO] \__pausing............20
[2024-07-23 15:38:22 DURATION] 4 minutes and 9 seconds elapsed.
[2024-07-23 15:38:22 COMPLETED] Done.
```

## Harvester install master1
```
$ ./03-install-harvester.sh
[2024-07-23 15:38:46 INFO] Collecting terraform output values..
lab-master1.test.suselabs.net 54.83.20.247 10.0.1.77 10.0.2.82 10.0.1.160
lab-master2.test.suselabs.net 3.219.127.55 10.0.1.221 10.0.2.95
lab-master3.test.suselabs.net 54.172.172.223 10.0.1.51 10.0.2.142

[2024-07-23 15:38:59 STARTED] Installing Harvester to (lab-master1.test.suselabs.net)..

[2024-07-23 15:38:59 INFO] \__Install harvester-bootstrap-repo (into cattle-system)..
deployment.apps/harvester-cluster-repo created
service/harvester-cluster-repo created
clusterrepo.catalog.cattle.io/harvester-charts created

[2024-07-23 15:39:04 INFO] \__create namespace harvester-system..
namespace/harvester-system created

[2024-07-23 15:39:04 INFO] \__Git clone harvester (-b master)..
Cloning into './local/harvester'...
remote: Enumerating objects: 59668, done.
remote: Counting objects: 100% (2/2), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 59668 (delta 0), reused 2 (delta 0), pack-reused 59666
Receiving objects: 100% (59668/59668), 66.51 MiB | 8.68 MiB/s, done.
Resolving deltas: 100% (32607/32607), done.
Updating files: 100% (10967/10967), done.

[2024-07-23 15:39:19 INFO] \__helm install harvester-crd..
NAME: harvester-crd
LAST DEPLOYED: Tue Jul 23 15:39:20 2024
NAMESPACE: harvester-system
STATUS: deployed
REVISION: 1
TEST SUITE: None

[2024-07-23 15:39:26 INFO] \__pausing............20

[2024-07-23 15:39:46 INFO] \__helm install harvester..
NAME: harvester
LAST DEPLOYED: Tue Jul 23 15:39:49 2024
NAMESPACE: harvester-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Harvester has been installed into "harvester-system" namespace with "harvester" as release name.

- [x] KubeVirt Operator
- [x] KubeVirt Resource named "kubevirt"
- [x] Longhorn
- [x] Harvester Network Controller

Please make sure there is a default StorageClass in the Kubernetes cluster.

To learn more about the release, try:

  $ helm status harvester -n harvester-system
  $ helm get all harvester -n harvester-system

[2024-07-23 15:40:11 INFO] \__pausing............300

[2024-07-23 15:45:11 INFO] \__load harvester addons..
namespace/cattle-monitoring-system created
addon.harvesterhci.io/rancher-monitoring created
addon.harvesterhci.io/vm-import-controller created

[2024-07-23 15:45:15 INFO] \__pausing............90

Access cluster at:
open https://lab-master1.test.suselabs.net

[2024-07-23 15:46:45 DURATION] 7 minutes and 59 seconds elapsed.
[2024-07-23 15:46:45 COMPLETED] Done.
```


