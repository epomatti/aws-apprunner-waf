# aws-apprunner

AWS App Runner + ECR sandbox.

Create the infrastructure:

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

```
docker build . -t <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/dotnet-app:latest
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/dotnet-app:latest
```

You'll need to publish an image to the AWS repository. A GitHub action is provided here.

Check the `app_runner_service_url` output variable to access the application.

### Local Testing

For local building the docker image:

```sh
docker build -t dotnet-app-image .
docker run --rm -p 80:80 --name dotnet-app dotnet-app-image
```

Running the .NET app:

```sh
dotnet restore
dotnet run
```
