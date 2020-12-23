

```bash
docker exec -it influx-control-plane cat /etc/kubernetes/manifests/etcd.yaml

kubectl run --rm -i --tty ubuntu --image=ubuntu:latest --restart=Never -- bash -il

```

# Docker

```bash
docker ps --format "table{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}"

```
