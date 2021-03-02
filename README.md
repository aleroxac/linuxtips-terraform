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


## Setup para rodar o Terraform localmente
``` shell
## Instalando dependências
sudo apt install -y wget unzip graphviz

## Baixando e instalando o Terraform localmente
wget -P /tmp https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
unzip /tmp/terraform*.zip
sudo mv /tmp/terraform /usr/local/bin

## Instalando o python3, pip, awscli
sudo apt install -y python3 python3-pip graphviz
sudo pip install awscli

## Configurando o awscli - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
aws configure

## Rodando o terraform
git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform

terraform init
terraform plan -out plan.out
terraform apply plan.out

# É importante ler o README.md dentro dos módulos para saber como usá-los
```


## Setup para rodar o Terraform via Docker
``` shell
## Instalando o docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ${USERNAME}
## Depois disso, caso não queira ficar usando o sudo, faça logout da sua sessão de usuário e logue-se novamente.

## Instalando o python3, pip, awscli
sudo apt install -y python3 python3-pip graphviz
sudo pip install awscli

## Configurando o awscli - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
aws configure

## Rodando o terraform
git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform

alias terraform="docker run \
    --rm \
    -v $PWD:/code \
    -w /code \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    hashicorp/terraform:light"

terraform init
terraform plan -out plan.out
terraform apply plan.out

# É importante ler o README.md dentro dos módulos para saber como usá-los
```




## Exemplo de utilização
``` shell
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ${USERNAME}

sudo apt install -y python3 python3-pip graphviz
sudo pip install awscli
aws configure

git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform
alias terraform="docker run \
    --rm \
    -v $PWD:/code \
    -w /code \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    hashicorp/terraform:light"


alias make="make -f scripts/docker/Makefile"
make terraform-init
make terraform-plan
make terraform-apply
make check-server
make check-nginx
```

## Módulos
* [aws-ec2](aws-ec2/README.md)
* [aws-ecs](aws-ecs/README.md)
* Caso queria criar apenas os recursos de um módulo, basta comentar o respectivo código dentro do arquivo [terrafile.tf](terrafile.tf) na raiz deste projeto.


## Referências
* https://github.com/gomex/terraform-module-groundwork
* https://github.com/gomex/terraform-module-fargate-deploy