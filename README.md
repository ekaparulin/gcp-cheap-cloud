# General

The goal of this repo is to run a very cheap GCP project (below 10$ per month) with:

- custom network
- firewall rules
- preemptible VM with on/off schedule
- customization boot scripts
- recreatable
- DNS + SSL updates

# Bootstrap


- Copy infra/terraform/projects/example to infra/terraform/projects/MYPROJECT
- Edit infra/terraform/projects/example to infra/terraform/projects/MYPROJECT/terraform.tfvars
- Create GCP bucket to store terraform state in and specify in infra/terrafor/projects/MYPROJECT/terraform.tf

```
gsutil mb -l europe-north1 -p PROJECT gs://PROJECT-terraform-state
```
- Run `terrafrom init`, `terraform apply`
  
# Modify VM with Ansible

