# CoderCo Tech Test

## Prerequisites

- Docker
- Kind
- Helm

## Setup

```bash
pip3 install -r requirements.txt

docker build -t ml-web-service .

helm install ml-web-service chart/

```

## Kind setup

```bash
kind create cluster --config kind.yml

helm install ml-web-service helm-chart/

http://localhost:8000
```
