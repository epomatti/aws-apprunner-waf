
# AWS App Runner + WAF

AWS App Runner using WAF rules.

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

The default image will be NGINX.

### Optional (ECR)

To use ECR, create the repository and set the variable `repository_url` for Terraform. The IAM permission is already built into the code.

```sh
aws ecr create-repository --repository-name dotnet-app
```

Build and publish the image:

```
docker build . -t <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/dotnet-app:latest
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/dotnet-app:latest
```

### Local Testing

Running the .NET app:

```sh
dotnet restore
dotnet run
```

For local building the docker image:

```sh
docker build -t dotnet-app-image .
docker run --rm -p 80:80 --name dotnet-app dotnet-app-image
```
