# Cloud Deployment

## Infrastructure Setup

To deploy the ML web service, we can use:

Compute:

- Use Amazon ECS (Elastic Container Service) or Kubernetes (via Amazon EKS, GKE, or AKS) for containerized deployments.
  - We can use ECS autoscaling if using ECS. And for EKS, we can use HPAs.
- Spot instances or auto-scaling groups in AWS EC2 for cost efficiency.

Networking:

- Set up a VPC with private and public subnets.
- Use a Load Balancer (ALB/ELB in AWS) to distribute incoming traffic to the service pods or tasks.
- Secure access using Security Groups and Network ACLs.

Storage:

- Possibly use Amazon S3 for storing large model weights and input/output data.
- Use Elastic File System (EFS) for shared storage across multiple instances/containers if required.

## Approach to Deployment at Scale

To deploy the application at scale:

- CI/CD Pipelines:
  - Implement pipelines using GitHub Actions, or GitLab CI/CD/Drone CI/CD for automating the build, test and deployment processes.
- Containerisation:
  - Use Docker containers and push the images to Amazon Elastic Container Registry (ECR) or another container registry (like Docker Hub or GCR).
- Helm or Kustomize:
  - Deploy the application using a Helm chart for Kubernetes or Task Definitions in EKS.
- Load Balancing:
  - Configure an Application Load Balancer (ALB) to handle traffic efficiently and route to appropriate services.

## Approach to Autoscaling

Autoscaling strategies include:

- Horizontal Pod Autoscaling (for Kubernetes):
  - Scale pods based on CPU, memory, or custom metrics.
  - Use Cluster Autoscaler to adjust the number of nodes dynamically.

- Task Autoscaling (for ECS):
  - ECS autoscaling can be used.
  - Configure scaling policies to add/remove tasks based on CPU utilization or request count.

- Event-Driven Scaling:
  - Utilise serverless solutions like AWS Lambda or Knative for on-demand compute scaling.
  - Integrate with message brokers like Apache Kafka for handling bursts of incoming data.

## Improving Storage of Model Weights

To efficiently manage and store model weights:

- S3 Object Storage:
  - Store the YOLOv8 model weights in Amazon S3 for scalability and cost-effectiveness.
  - Use S3 Transfer Acceleration for faster data access.

- Caching:
  - Implement a caching layer using Amazon ElastiCache (Redis) or Memcached to reduce repetitive data fetching.

- Version Control:
  - Use a model versioning tool like DVC or MLflow to manage updates and rollbacks effectively.

## Third-Party Solutions for ML Deployments

The following third-party solutions can simplify and enhance ML deployments:

- SageMaker:
  - AWS SageMaker provides end-to-end capabilities for model training, hosting, and inference.
  - It integrates with Kubernetes for model inference endpoints.

- TensorFlow Serving / TorchServe:
  - Dedicated tools for deploying machine learning models in production.

- Kubeflow:
  - Extend Kubernetes capabilities to handle ML workloads with optimized pipelines and monitoring.

- Databricks:
  - Utilize Databricks for collaborative model training and deployment.

- Weights & Biases (W&B):
  - Monitor and log training and deployment metrics for better insights.