# CoderCo Tech Test

## What is this?

This is a simple FastAPI application that uses a YOLO model to detect objects in images.

## Prerequisites

- Docker
- Kind
- Helm

## Make automations

```sh

- `make setup` - Create Kind cluster and install nginx-ingress
- `make build` - Build Docker image
- `make load` - Load Docker image into Kind cluster
- `make deploy` - Deploy application using Helm
- `make test` - Test the deployed application
- `make clean` - Remove deployment and cluster
- `make all-in-one` - Run complete setup
- `make redeploy` - Rebuild and redeploy the application
- `make logs` - View application logs
- `make status` - Check deployment status
```

## Local Setup

```bash

python3 -m venv venv
source venv/bin/activate

pip3 install -r requirements.txt

python3 app/main.py
```

## Containers Setup

```sh
docker build -t ml-web-service .

docker run -p 8000:8000 ml-web-service

curl http://localhost:8000/

cd app
curl -X POST -F "file=@test_car.jpg" http://localhost:8000/detect

```

## Kind setup

```bash
kind create cluster --config kind.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kind load docker-image ml-web-app:3bcc279

helm install ml-web-service chart/

# Check all resources
kubectl get pods,svc,ingress

# Test the endpoints
curl http://ml-app.localhost/
curl -X POST -F "file=@app/test_car.jpg" http://ml-app.localhost/detect

## Cleanup
helm uninstall ml-web-service
kind delete cluster
```

## Full Local K8s Setup

```sh
make all-in-one
```
