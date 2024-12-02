# Variables
CLUSTER_NAME ?= ml-cluster
HELM_RELEASE_NAME ?= ml-web-service
DOCKER_IMAGE ?= ml-web-service
DOCKER_TAG ?= latest
HOST_PORT ?= 9090
HTTPS_PORT ?= 9443

# .PHONY: clean-ports
# clean-ports:
# 	@echo "Cleaning up any existing Docker containers using our ports..."
# 	-docker container ls -q | xargs -r docker container stop
# 	-docker container ls -a -q | xargs -r docker container rm
# 	@echo "Waiting for ports to be released..."
# 	@sleep 5

#########################
# Python
#########################

.PHONY: python-local
python-local:
	@echo "Setting up the application locally..."
	cd app && python3 -m venv venv && \
	source venv/bin/activate && \
	pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu && \
	pip3 install --upgrade pip && \
	pip3 install -r requirements.txt && \
	python3 main.py
	@echo "Local setup complete. The app is running at http://127.0.0.1:8000"

.PHONY: python-clean
python-clean:
	@echo "Cleaning up Python virtual environment and related files..."
	@rm -rf app/venv
	@find app -type f -name "*.pyc" -delete
	@find app -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Python cleanup complete."


#########################
# Container & K8s
#########################

# .PHONY: check-docker
# check-docker:
# 	@echo "Checking Docker..."
# 	@if ! docker info > /dev/null 2>&1; then \
# 		echo "Docker is not running. Please start Docker."; \
# 		exit 1; \
# 	fi

.PHONY: clean
clean:
	@echo "Cleaning up..."
	-helm uninstall $(HELM_RELEASE_NAME) 2>/dev/null || true
	-kind delete cluster --name $(CLUSTER_NAME) 2>/dev/null || true
	@echo "Cleanup complete"
	@sleep 5

.PHONY: setup
setup:
	@echo "Creating Kind cluster..."
	kind create cluster --name $(CLUSTER_NAME) --config kind.yml
	@echo "Installing NGINX Ingress Controller..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Waiting for Ingress Controller pods to be created..."
	sleep 30
	@echo "Waiting for Ingress Controller to be ready..."
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s || \
	(echo "Ingress pods status:" && \
	 kubectl get pods -n ingress-nginx && \
	 kubectl describe pods -n ingress-nginx && \
	 exit 1)
	@echo "Verifying Ingress Controller..."
	kubectl get pods -n ingress-nginx

.PHONY: build
build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	docker run -p 8000:8000 $(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: build-rancher
build-rancher:
	@echo "Building Docker image..."
	nerdctl build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	nerdctl run -p 8000:8000 $(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: load
load:
	@echo "Loading Docker image into Kind cluster..."
	kind load docker-image $(DOCKER_IMAGE):$(DOCKER_TAG) --name $(CLUSTER_NAME)

.PHONY: deploy
deploy:
	@echo "Deploying application using Helm..."
	helm install $(HELM_RELEASE_NAME) chart/ || helm upgrade $(HELM_RELEASE_NAME) chart/

.PHONY: all-in-one
all-in-one: setup deploy
	@echo "Complete setup finished!"
	@echo "Waiting for all services to start..."
	sleep 10
	@make test
	@echo "\nApplication is available at: http://ml-app.localhost:$(HOST_PORT)"

.PHONY: test
test:
	@echo "Testing deployment..."
	@echo "Checking all resources..."
	kubectl get pods,svc,ingress
	@echo "\nWaiting for pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=$(HELM_RELEASE_NAME) --timeout=150s
	@echo "\nTesting health endpoint (http://ml-app.localhost:$(HOST_PORT))..."
	curl -s http://ml-app.localhost:$(HOST_PORT)/
	@echo "\nTesting ML endpoint with test image and saving to k8s-test-output.json..."
	@curl -s -X POST -F "file=@images/test_car.jpg" http://ml-app.localhost:$(HOST_PORT)/detect > k8s-test-output.json
	@echo "\nPrediction results saved to k8s-test-output.json"
	@echo "\nContents of k8s-test-output.json:"
	@cat k8s-test-output.json | jq '.' || cat k8s-test-output.json

.PHONY: status
status:
	@echo "Cluster Status:"
	@echo "Pods:"
	kubectl get pods
	@echo "\nServices:"
	kubectl get svc
	@echo "\nIngress:"
	kubectl get ingress

.PHONY: logs
logs:
	@echo "Fetching application logs..."
	kubectl logs -l app=$(HELM_RELEASE_NAME) --tail=100 -f