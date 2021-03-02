# aws-ec2

## O que este módulo faz?
* Cria um par de chaves privada e pública do tipo RSA
* Cria um par de chaves na AWS, a partir do par criado anteriormente
* Cria um Security Group
* Cria uma instância EC2

## Grafo
[Grafo do recursos criados por este módulo](../ec2-graph.svg)

## Modo de uso - makefile
``` shell
# Os comandos abaixo devem ser executados a partir da raiz do projeto, não de dentro dos módulos

# Criei 2 makefiles, um para rodar o Terraform localmente e outro para Docker.
# Escolha um deles e rode os comandos abaixo, de acordo com o arquivo escolhido.
source .env

## Inicializando provider, formatando e validando o script
make init
make create-workspace
make select-workspace

## Rodando o script
make terraform-plan
make terraform-apply

## Visualizando recursos criados
make dot-install
make terraform-graph
make terraform-list

## Checando EC2 e serviço do Nginx
make check-server
make check-nginx

## Destruindo os recursos
make destroy
make list
```

## Modo de uso - manual
``` shell
# Os comandos abaixo devem ser executados a partir da raiz do projeto, não de dentro dos módulos

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

## Adicionando chave privada no ssh-agent, a partir de uma variável de ambiente
private_key=$(terraform output -raw private_key)
eval $(ssh-agent -s)
ssh-add <(echo "${private_key}")

## Checando Nginx e validando informações sobre o a instância EC2
server_ip=$(terraform output -raw public_ip)
curl -s ${server_ip}
ssh ubuntu@${server_ip} 'cat /etc/os-release; echo -e "\nsg: $(curl -s http://169.254.169.254/latest/meta-data/security-groups)"'

## Destruindo os recursos
terraform plan -destroy -out "plan"
terraform destroy "plan"
terraform state list
```


## Inputs
|     Nome     |      Descrição       | Tipo | Padrão  | Obrigatório |
|--------------|----------------------|:----:|:-------:|:-----------:|
| env          | Nome do ambiente     |string|   dev   |     sim     |
| service_name | Nome do serviço      |string|  nginx  |     sim     |

## Outputs
|    Nome     |                  Endereço                  |
|-------------|--------------------------------------------|
| private_key | tls_private_key.private_key.private_key_pem|
| public_ip   | aws_instance.ec2_instance.public_ip        |