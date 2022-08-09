# aws-apprunner

AWS App Runner + ECR sandbox.

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

You'll need to publish an image to the AWS repository. A GitHub action is provided here.

Check the `app_runner_service_url` output variable to access the application.

### Local Testing

For local building the docker image:

```sh
docker build -t dotnet-app-image .
docker run --rm -p 80:80 --name dotnet-app dotnet-app-image
```

```sh
docker run 
```

Running the .NET app:

```sh
dotnet restore
dotnet run
```
