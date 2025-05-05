# 04-Terraform-AWS---Remote-State-with-S3-and-DynamoDB-Locking

Now that We have the S3 bucket + DynamoDB table ready via the Bootstrap Lab, Let’s move to the Next Lab, where we actually use that backend properly with state locking.

![alt text](/Images/Pravash_Logo_Small.png)

## Objective

> In this lab, we will:
> - Configure Terraform to store the state file in a remote S3 bucket.
> - Enable state locking using DynamoDB.
> - Perform Terraform operations using this secure remote backend.

## Pre-requisites
 - Completed 03-Terraform-AWS---Bootstrap-Remote-Backend-S3-DynamoDB lab successfully
 - S3 bucket and DynamoDB table already created:
    -   S3 bucket: terraform-bootstrap-pro-lab
    -   DynamoDB table: terraform-lock-pro-lab
- Terraform Installed
- AWS CLI configured

## Folder Structure
```
04-Terraform-AWS---Remote-State-with-S3-and-DynamoDB-Locking/
├── main.tf
├── provider.tf
├── variables.tf
├── backend.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

## Step 1: Files to Create

![alt text](/Images/image.png)

1. `provider.tf`

```
provider "aws" {
  region = var.aws_region
}
```

2. `variables.tf`
```
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
```
3. `terraform.tfvars`
```
aws_region = "us-east-1"
```
4. `backend.tf`
```
terraform {
  backend "s3" {
    bucket         = "terraform-bootstrap-pro-lab"
    key            = "projects/sample-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-pro-lab"
    encrypt        = true
  }
}
```
> **WHAT AND WHY?**
> - **bucket**: Stores the terraform state file remotely.
> - **key**: The logical folder structure inside the bucket.
> - **dynamodb_table**: Locks the state file when apply/plan runs.
> - **encrypt**: Encrypt the state at rest.

5. `main.tf`
Let's deploy a very simple AWS resource (for testing).
```
resource "aws_s3_bucket" "example" {
  bucket = "sample-app-pro-${random_integer.suffix.result}"
  
  tags = {
    Name = "SampleAppBucket"
  }
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}
```
> **I'm using a `random_integer` to avoid bucket name conflicts!**

6. `outputs.tf`
```
output "sample_bucket_name" {
  description = "Name of the created sample S3 bucket"
  value       = aws_s3_bucket.example.id
}
```

## Step 2: Commands to Run

1. Initialize Terraform:
```
terraform init
```
![alt text](/Images/image-1.png)
> - This has initialized the backend and connnected to the S3 bucket (terraform-bootstrap-pro-lab)
> - It has also checked, if DynamoDB locking works.

2. Validate the terraform files:
```
terraform validate
```
![alt text](/Images/image-2.png)

3. Let's now Plan the infrastructure:
```
terraform plan -out=tfplan
```
![alt text](/Images/image-3.png)
4. Apply:
```
terraform apply tfplan
```
![alt text](/Images/image-4.png)
We can see the resources have been created.

## After Apply
1. Let's go to our AWS Account and we could see the state file inside the S3 bucket:
`terraform-bootstrap-pro-lab/projects/sample-app/terraform.tfstate`
![alt text](/Images/image-5.png)
2. During plan/apply, the **DynamoDB** table will show locks like this:

    | LockID                                | Info                  |
    | :------------------------------------ | :-------------------- |
    | projects/sample-app/terraform.tfstate | Locked while applying |
3. We can also see the `sample-app-pro-<random_integer>` bucket has been created.
![alt text](/Images/image-6.png)

## Clean Up
Now, We'll destroy the sample resources created:
```
terraform destroy
```
![alt text](/Images/image-7.png)
> ## State Still remains safely in S3 even after the bucket is destroyed!
![alt text](/Images/image-8.png)
![alt text](/Images/image-9.png)


