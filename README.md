# Aline Financial Cloud Infrastructure
This repository contains a series of projects whose purpose is to provision and configure the cloud infrastructure for the Aline Financial application.

## **Terraform**
Terraform is used to provision the cloud infrastructure for this project. The provider used in this project is AWS.
### [**Main Stack**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/terraform/main_stack)
A group of Terraform modules and configuration files that provision the main Aline Financial cloud infrastructure stack.
### [**Ansible Playbooks Demo**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/terraform/ansible_playbooks_demo)
Terraform configuration files for provisioning a control and worker nodes to demonstrate Ansible capabilities.
### [**Ansible Tower Demo**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/terraform/awx)
Terraform configuration files for provisioning an AWS EC2 instance which serves as the AWX server. The configuration files specify a series of commands executed through the `remote-exec` provisioner in order to have AWX installed and running upon provisioning of the EC2 instance.    

## [**Ansible**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/ansible)
A collection of Ansible configuration files and playbooks for configuration of cloud infrastructure.

## [**CloudFormation**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/cloudformation)
A CloudFormation template to provision the entire Aline Financial cloud stack.

## [**Jenkinsfile**](https://github.com/SebastianMarzal/aline-infrastructure/blob/main/Jenkinsfile)
Jenkinsfile for CI/CD of infrastructure.

## [**Python**](https://github.com/SebastianMarzal/aline-infrastructure/tree/main/lambda)
AWS Lambda functions written in Python for automation of cost control measures.