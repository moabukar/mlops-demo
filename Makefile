# Variables
CLUSTER_NAME ?= ml-cluster
HELM_RELEASE_NAME ?= ml-web-service
DOCKER_IMAGE ?= ml-web-service
DOCKER_TAG ?= latest

.PHONY: all
all: help

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make setup         - Create Kind cluster and install nginx-ingress"
	@echo "  make build        - Build Docker image"
	@echo "  make load         - Load Docker image into Kind cluster"
	@echo "  make deploy       - Deploy application using Helm"
	@echo "  make test         - Test the deployed application"
	@echo "  make clean        - Remove deployment and cluster"
	@echo "  make all-in-one   - Run complete setup (setup, build, load, deploy)"
	@echo "  make redeploy     - Rebuild and redeploy the application"

.PHONY: setup
setup:
	@echo "Creating Kind cluster..."
	kind create cluster --name $(CLUSTER_NAME) --config kind.yml
	@echo "Installing NGINX Ingress Controller..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Waiting for Ingress Controller to be ready..."
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s

.PHONY: build
build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

.PHONY: load
load:
	@echo "Loading Docker image into Kind cluster..."
	kind load docker-image $(DOCKER_IMAGE):$(DOCKER_TAG) --name $(CLUSTER_NAME)

.PHONY: deploy
deploy:
	@echo "Deploying application using Helm..."
	helm install $(HELM_RELEASE_NAME) chart/ || helm upgrade $(HELM_RELEASE_NAME) chart/

.PHONY: test
test:
	@echo "Testing deployment..."
	@echo "Waiting for pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=$(HELM_RELEASE_NAME) --timeout=90s
	@echo "Testing health endpoint..."
	curl -s http://ml-app.localhost/
	@echo "\nTesting ML endpoint with test image..."
	curl -X POST -F "file=@app/test_car.jpg" http://ml-app.localhost/detect

.PHONY: clean
clean:
	@echo "Cleaning up..."
	-helm uninstall $(HELM_RELEASE_NAME)
	-kind delete cluster --name $(CLUSTER_NAME)
	@echo "Cleanup complete"

.PHONY: all-in-one
all-in-one: setup build load deploy
	@echo "Complete setup finished!"
	@echo "Wait a few moments for all services to start, then run: make test"

.PHONY: redeploy
redeploy: build load
	@echo "Redeploying application..."
	helm upgrade $(HELM_RELEASE_NAME) chart/

.PHONY: logs
logs:
	@echo "Fetching application logs..."
	kubectl logs -l app=$(HELM_RELEASE_NAME) --tail=100 -f

.PHONY: status
status:
	@echo "Cluster Status:"
	@echo "Pods:"
	kubectl get pods
	@echo "\nServices:"
	kubectl get svc
	@echo "\nIngress:"
	kubectl get ingress