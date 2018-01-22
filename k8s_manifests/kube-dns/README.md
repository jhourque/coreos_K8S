#Kubernetes DNS

kude-dns configured for current K8S config (coredns not tested)
See [a link](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns)

## Install kube-dns
```
kubectl create -f kude-dns.yml
```

## Check kube-dns
```
kubectl --namespace=kube-system get deploy,svc,pods 
```
