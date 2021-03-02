# aws-ecs

## O que este módulo faz?
* Cria uma Zona no Route53
* Cria um Application Load Balancer
* Cria um Target Group
* Cria um repositório no ECR
* Cria um Cluster no ECS
* Cria uma Task Definition no ECS
* Cria um Service no ECS

## Grafo
[Grafo do recursos criados por este módulo](resources/graph.svg)

## Modo de uso - makefile
``` shell
# Os comandos abaixo devem ser executados a partir da raiz do projeto, não de dentro dos módulos
source .env

## Inicializando provider, formatando e validando o script
make init
make create-workspace
make select-workspace

## Rodando o script
make plan
make apply

## Visualizando recursos criados
make dot-install
make graph
make show

## Baixando a imagem do nginx, criando tag e fazendo push para o ECR
make push

## Checando o serviço do Nginx
make check-nginx

## Destruindo os recursos
make destroy
make list
```

## Modo de uso - manual
``` shell
# Os comandos abaixo devem ser executados a partir da raiz do projeto, não de dentro dos módulos
source .env

## Inicializando provider, formatando e validando o script
terraform init
terraform workspace new prod
terraform workspace select prod
terraform fmt -check -diff --recursive
terraform validate -json **/*.tf

## Rodando o script
terraform plan -out "plan"
terraform apply "plan"

## Visualizando recursos criados
sudo apt install -y graphviz
terraform graph | /bin/dot -Tsvg > svg/graph.svg
xdg-open aws-ec2/resources/graph.svg
terraform state list
terraform output
terraform show

## Baixando a imagem do nginx, criando tag e fazendo push para o ECR
ecr_repo=$(terraform output -raw ecr_repo)
aws ecr get-login-password --region us-east-1 | xargs -I xxx docker login -u AWS -p  xxx https://${ecr_repo}
docker pull nginx:latest
docker tag nginx:latest ${ecr_repo}:latest
docker push ${ecr_repo}:latest

## Checando o serviço do Nginx
fqdn=$(terraform output -raw fqdn)
curl -fsSL ${fqdn}

## Destruindo os recursos
terraform plan -destroy -out "plan"
terraform destroy -out-approve
terraform state list
```




## Inputs
| Nome         | Descrição            | Tipo | Padrão  | Obrigatório |
|--------------|----------------------|:----:|:-------:|:-----------:|
| env          | Name of environment  |string|dev      |yes          |
| service_name | Name of service      |string|nginx    |yes          |

## Outputs
| Nome              | Endereço                                   |
|-------------------|--------------------------------------------|
| zone_id           | aws_route53_zone.route53_zone.zone_id      |
| zone_name_servers | aws_route53_zone.route53_zone.name_servers |
| ecr_repo          | aws_ecr_repository.ecr_repo.repository_url |