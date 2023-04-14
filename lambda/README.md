# Lambda functions
This folder contains the Python code to be run within Lambda functions whose purpose is ensuring the reduction of infrastructure costs.

## stop-delete-midnight.py
This function's purpose is to delete/stop all resources that are prone to accrue high costs when left on during development (EKS Clusters, RDS Instances, EC2 Instances, etc.)