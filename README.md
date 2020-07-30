![Kind Calico](https://github.com/mchirico/kind/workflows/Kind%20Calico/badge.svg)
![Kind CertManager](https://github.com/mchirico/kind/workflows/Kind%20CertManager/badge.svg)
![Kind Kudo](https://github.com/mchirico/kind/workflows/Kind%20Kudo/badge.svg)
# kind


## Kind with Calico and Nginx Ingress

```
make calico
```


```
kubectl exec -it node-starter-deploy-7d7b887466-gvrb7 -- /bin/sh

```

## Trouble Shooting

```
docker exec -it kind-worker  /bin/bash
docker exec -it kind-control-plane  /bin/bash

```

## Metrics

Ref: https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml

kubectl create namespace prometheus
helm install prometheus stable/prometheus \
    --namespace prometheus


```
