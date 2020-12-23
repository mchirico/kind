PROJECT = septapig
NAME = kindstarter
TAG = dev

K8S_VERSION = v1.20.1-rc.1

ifndef $(GOPATH)
  export GOPATH=${HOME}/gopath
  ${shell mkdir -p ${GOPATH}}
endif

ifndef $(GOBIN)
  export GOBIN=${GOPATH}/bin
endif


.PHONY: calico
calico:
	kind delete cluster
	kind create cluster --config calico/kind-calico.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml


.PHONY: jaeger
jaeger:
	kubectl create namespace observability
	kubectl create -f jaeger/jaegertracing.io_jaegers_crd.yaml # <2>
	kubectl create -n observability -f jaeger/service_account.yaml
	kubectl create -n observability -f jaeger/role.yaml
	kubectl create -n observability -f jaeger/role_binding.yaml
	kubectl create -n observability -f jaeger/operator.yaml
	kubectl create -f jaeger/cluster_role.yaml
	kubectl create -f jaeger/cluster_role_binding.yaml


.PHONY: calicoctl
calicoctl:
	 kubectl exec -ti -n kube-system calicoctl -- /calicoctl get profiles -o wide


.PHONY: cert-manager
cert-manager:
	kind delete cluster
	kind create cluster --config calico/kind-calico.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
#	kubectl kudo init


.PHONY: v1.20
v1.20:
	mkdir -p ${HOME}/gopath
	go get k8s.io/kubernetes || true
	cd ${HOME}/gopath/src/k8s.io/kubernetes && git checkout v1.20.1-rc.1 || git pull
	go get sigs.k8s.io/kind
	export PATH=${HOME}/bin:${PATH}
#     Node image
	kind build node-image --image=master
	kind delete cluster
	kind create cluster --image=master --config calico/kind-calico81.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
#	kubectl kudo init



.PHONY: pvc
pvc:
	mkdir -p ${HOME}/gopath
	go get k8s.io/kubernetes || true
	cd ${HOME}/gopath/src/k8s.io/kubernetes && git checkout $(K8S_VERSION)
	go get sigs.k8s.io/kind
	export PATH=${HOME}/bin:${PATH}
#     Node image
	kind build node-image --image=master
	kind delete cluster
	kind create cluster --image=master --config calico/kind-calico-pvc.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
	sleep 20
	kubectl apply -f pvc/.


.PHONY: pvc2
pvc2:
	mkdir -p ${HOME}/gopath
	go get k8s.io/kubernetes || true
	cd ${HOME}/gopath/src/k8s.io/kubernetes && git checkout $(K8S_VERSION)
	go get sigs.k8s.io/kind
	export PATH=${HOME}/bin:${PATH}
#     Node image
	kind build node-image --image=master
	kind delete cluster
	kind create cluster --image=master --config calico/kind-calico-pvc2.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
	sleep 20
#	kubectl apply -f pvc2/.



.PHONY: influx
influx:
	mkdir -p ${HOME}/gopath
	go get k8s.io/kubernetes || true
	cd ${HOME}/gopath/src/k8s.io/kubernetes && git checkout $(K8S_VERSION)
	go get sigs.k8s.io/kind
	export PATH=${HOME}/bin:${PATH}
#     Node image
	kind build node-image --image=master
	kind delete cluster
	kind create cluster --name influx --image=master --config calico/kind-calico-pvc2.yaml
	kubectl apply -f calico/ingress-nginx-8086.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
	sleep 20
#	kubectl apply -f pvc2/.


.PHONY: basic
basic:
	kind delete cluster --name basic
	kind create cluster --name basic --image=master 
#	kubectl apply -f pvc2/.



.PHONY: dev
dev:

#     Node image
	kind create cluster --image=master --config calico/kind-calico-pvc2.yaml
	kubectl apply -f calico/ingress-nginx-8086.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
	sleep 40
#	kubectl apply -f pvc2/.
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"




.PHONY: dev
dev:

#     Node image
	kind create cluster --image=master --config calico/kind-calico-pvc2.yaml
	kubectl apply -f calico/ingress-nginx-8086.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
	sleep 40
#	kubectl apply -f pvc2/.
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"



.PHONY: istio
istio:
#     Node image
	kind delete cluster --name istio
	kind create cluster --name istio --image=master --config istio/istio.yaml
#
#	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
#	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
#	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"



.PHONY: reload
reload:
	kind delete cluster
	kind create cluster --image=master --config calico/kind-calico.yaml
	kubectl apply -f calico/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
#	kubectl kudo init


.PHONY: cert-manager
cert-manager-mce:
	kind delete cluster
	kind create cluster --config calico-mce/kind-calico.yaml
	kubectl apply -f calico-mce/ingress-nginx.yaml
	kubectl apply -f calico/tigera-operator.yaml
	kubectl apply -f calico/calicoNetwork.yaml
	kubectl apply -f calico/calicoctl.yaml
	kubectl apply -f calico/cert-manager.yaml
#	kubectl kudo init



.PHONY: packages
packages:
	kubectl kudo init
	kubectl kudo install zookeeper
	kubectl kudo install kafka
	kubectl kudo install redis
	kubectl kudo install mysql
	kubectl kudo install rabbitmq


.PHONY: sample
sample:
	rm -rf express.zip
	rm -rf node-starter-express
	curl -LO https://github.com/mchirico/node-starter/archive/express.zip
	unzip express.zip
	cd node-starter-express
	npm install


# Danger This Cleans Up Everything!
.PHONY: cleanup
cleanup:
	docker stop $(docker ps -aq)
	docker rm $(docker ps -aq)
	docker rmi $(docker images -q)


.PHONY: docker-build
docker-build:
	docker build --no-cache -t gcr.io/$(PROJECT)/$(NAME):$(TAG) -f Dockerfile .

.PHONY: kind
kind:
	kind load docker-image gcr.io/$(PROJECT)/$(NAME):$(TAG)

.PHONY: push
push:
	docker push gcr.io/$(PROJECT)/$(NAME):$(TAG) 

.PHONY: pull
pull:
	docker pull gcr.io/$(PROJECT)/$(NAME):$(TAG) 



.PHONY: run
run:
	docker run -p 3000:3000 --rm -it -d --name $(NAME) gcr.io/$(PROJECT)/$(NAME):$(TAG) 


.PHONY: runnod
runnod:
	docker run -p 3000:3000 --rm -it --name $(NAME) gcr.io/$(PROJECT)/$(NAME):$(TAG) 

.PHONY: stop
stop:
	docker stop $(NAME)


.PHONY: logs
logs:
	docker logs $(NAME)



