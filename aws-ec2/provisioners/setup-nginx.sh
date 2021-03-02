#!/usr/bin/env bash

## Instalando o docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

## Rodando um container do Nginx
docker run -p 80:80 -d nginx

## Check if Nginx service is ready
while [[ $(curl -s -o /dev/null -w "%{http_code}" http://localhost) != 200 ]]; do
    sleep 10s
done