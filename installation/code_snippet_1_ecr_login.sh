– התחברות ל-ECR
```bash
account_id=$(aws sts get-caller-identity --query "Account" --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $account_id.dkr.ecr.us-east-1.amazonaws.com
```