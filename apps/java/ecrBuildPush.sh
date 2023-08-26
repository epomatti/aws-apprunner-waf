#!/bin/bash

localTag="javaapp-local"
acr=acrepicservicex
image="$acr.azurecr.io/javaapp:latest"

docker build -t $localTag .
az acr login --name $acrName
docker tag $localTag $image
docker push $image