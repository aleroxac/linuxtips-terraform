# linuxtips-terraform
![packer-logo](https://i.pinimg.com/originals/f4/54/15/f45415270449af33c39dcb1e8af5a62a.png)

Projeto com scripts do Terraform criados a partir do conteúdo assimilado durante treinamento Descomplicando Terraform da LINUXtips.


## Recursos
- [x] aws resources
- [x] random_shuffle resource
- [x] tls resource
- [x] http data source
- [x] external data source
- [x] local variables
- [x] input variables
- [x] number and string variables
- [x] outputs
- [x] remote state
- [x] encrypted state
- [x] conditional expressions
- [x] splat expressions
- [x] providers
- [x] backends
- [x] workspaces
- [x] modules


## Instalação
``` shell
sudo apt install -y wget unzip

wget -P /tmp https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
unzip /tmp/terraform*.zip
sudo mv /tmp/terraform /usr/local/bin
```


## Setup para rodar o Terraform via Docker
``` shell
## Instalando o docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ${USERNAME}

## Depois disso, caso não queira ficar usando o sudo, faça logout da sua sessão de usuário e logue novamente para conseguir usar o docker.
## Caso não faça o logout/login, terá que rodar os comandos do docker com sudo na frente.

## Instalando o python3, pip, awscli
sudo apt install -y python3 python3-pip graphviz
sudo pip install awscli

## Rodando o terraform
git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform

docker run \
    --rm \
    -v $PWD:/code \
    -w /code \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    hashicorp/terraform:light "plan"


```


## Modo de uso - makefile
``` shell
# Criei 2 makefiles, um para rodar o Terraform localmente e outro para Docker.
# Escolha um deles e rode os comandos abaixo, de acordo com o arquivo escolhido.
alias make="make -f docker.makefile"

## Inicializando provider, formatando e validando o script
make terraform-init
make terraform-create-workspace
make terraform-select-workspace
make terraform-format
make terraform-validate

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
make terraform-plan-destroy
make terraform-destroy
make terraform-list
```

## Modo de uso - manual
``` shell
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
terraform graph | /bin/dot -Tsvg > graph.svg
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

