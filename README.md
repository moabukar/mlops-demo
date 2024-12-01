# CoderCo Tech Test

## Prerequisites

- Docker
- Kind
- Helm

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

helm install ml-web-service chart/

http://localhost:8000
```
