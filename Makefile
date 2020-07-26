PROJECT = septapig
NAME = kindstarter
TAG = dev


.PHONY: calico
calico:
	kind delete cluster
	kind create cluster --config calico/kind-calico.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
	kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml


.PHONY: kudo
kudo:
	kind delete cluster
	kind create cluster --config kudo/kind-kudo.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
	kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
	kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.yaml
#	kubectl kudo init


.PHONY: docker-build
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

.PHONY: deploy
deploy:
	gcloud config set gcloudignore/enabled false --project $(PROJECT)
	gcloud builds submit --tag gcr.io/$(PROJECT)/$(NAME)cloud --project $(PROJECT) --timeout 35m23s
	gcloud run deploy $(NAME)cloud --image gcr.io/$(PROJECT)/$(NAME)cloud \
              --platform managed --allow-unauthenticated --project $(PROJECT) \
              --region us-east1 --port 3000 --max-instances 3  --memory 128Mi


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



