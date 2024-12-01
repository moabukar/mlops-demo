# Architectures

## Local in Kind

```mermaid
graph TD
    subgraph "Local Machine"
        A1[Docker Engine] --> A2[kind Cluster]
        subgraph "kind Cluster"
            B1[Control Plane Node] --> B2[Worker Node 1]
            B1 --> B3[Worker Node 2]
            subgraph "Worker Nodes"
                C1[Pod: FastAPI Service] --> C2[YOLOv8 Model]
                C3[Pod: NGINX Ingress Controller] --> C1
            end
        end
    end
    D[Local Host] --> C3


```

## Architecture on AWS

```mermaid

```
