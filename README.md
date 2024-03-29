# AWS App Runner + WAF & X-Ray

AWS App Runner using WAF rules.

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

The default image will be NGINX.

## WAF

Customize WAF rules behavior:

```terraform
waf_allowed_country_codes = ["BR", "US"]
```

To test the rate-limiting rule, run a loop and verify in another terminal when it starts blocking. Example:

```sh
bash loop.sh https://<app_id>.us-east-2.awsapprunner.com
```

Blocked requests should have a custom message:

<img src=".assets/wafed.png" width=400 />

## Body size

Following this [guideline][1], WAF is configured with `AWS Managed Rules Core` rule set to limit requests in the `/post` endpoint to 8,192 bytes. Requests with more than that will be blocked.

An exception is added to the `/put` route, which will allow requests to go through.

It is important to notice the limits of inspection as well:

> AWS WAF inspects the first 8 KB (8,192 bytes) of the request body. This is a hard service limit and can't be changed.

To teste different options, use the Insomnia project export.

## Optional (ECR)

To use ECR, configure the `.auto.tfvars` file before creating the resources:

```sh
bash ecrPushHttpbin.sh
```

Also, uncomment the ECR authentication:

```terraform
authentication_configuration {
  access_role_arn = var.access_role_arn
}
```

Create the repository:

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

[1]: https://repost.aws/knowledge-center/waf-http-request-body-inspection
