# Code 1: Authorize Docker client to connect to Amazon ECR
account_id=$(aws sts get-caller-identity |grep Account|cut -d '"' -f4)
echo $account_id
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $account_id.dkr.ecr.us-east-1.amazonaws.com

# Code 2: Tag Docker images with registry ID
docker tag customer:latest $account_id.dkr.ecr.us-east-1.amazonaws.com/customer:latest
docker tag employee:latest $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest

# Code 3: Push Docker images to Amazon ECR
docker push $account_id.dkr.ecr.us-east-1.amazonaws.com/customer:latest
docker push $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest

# Code 4: Register ECS Task Definition
aws ecs register-task-definition --cli-input-json "file:///home/ec2-user/environment/deployment/taskdef-customer.json"
aws ecs register-task-definition --cli-input-json "file:///home/ec2-user/environment/deployment/taskdef-employee.json"

# Code 5: Create ECS Service for Customer Microservice
cd ~/environment/deployment
aws ecs create-service --service-name customer-microservice --cli-input-json file://create-customer-microservice-tg-two.json

# Code 6: Create ECS Service for Employee Microservice
cd ~/environment/deployment
aws ecs create-service --service-name employee-microservice --cli-input-json file://create-employee-microservice-tg-two.json

# Code 7: Update desired count (scale service) for customer microservice
aws ecs update-service --cluster microservices-serverlesscluster --service customer-microservice --desired-count 3

# Code 8: Rebuild Docker image and push updated employee microservice image
docker rm -f employee_1 
cd ~/environment/microservices/employee
docker build --tag employee .
dbEndpoint=$(cat ~/environment/microservices/employee/app/config/config.js | grep 'APP_DB_HOST' | cut -d '"' -f2)
account_id=$(aws sts get-caller-identity |grep Account|cut -d '"' -f4)
docker tag employee:latest $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $account_id.dkr.ecr.us-east-1.amazonaws.com
docker push $account_id.dkr.ecr.us-east-1.amazonaws.com/employee:latest