#!/bin/bash

account=$(aws sts get-caller-identity --query "Account" --output text)
region="us-east-2"
tag="latest"

docker pull kennethreitz/httpbin:latest
docker tag kennethreitz/httpbin "$account.dkr.ecr.$region.amazonaws.com/apprunner-waf:$tag"
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$account.dkr.ecr.$region.amazonaws.com"
docker push "$account.dkr.ecr.$region.amazonaws.com/apprunner-waf:$tag"
