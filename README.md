# linuxtips-terraform
![packer-logo](https://i.pinimg.com/originals/f4/54/15/f45415270449af33c39dcb1e8af5a62a.png)

Projeto com scripts do Terraform criados a partir do conteúdo assimilado durante treinamento Descomplicando Terraform da LINUXtips.


## Rodando terraform via docker
``` shell
## Instalando o docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ${USERNAME}

## Depois disso, caso não queira ficar usando o sudo, faça logout da sua sessão de usuário e logue novamente para conseguir usar o docker.
## Caso não faça o logout/login, terá que rodar os comandos do docker com sudo na frente.

## Instalando o python3, pip, awscli
sudo apt install -y python3 python3-pip
sudo pip install awscli

## Rodando o terraform
git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform
docker run --rm -v $PWD:/code -w /code --entrypoint "" -it hashicorp/terraform:light sh

## Dentro do container
terraform init
terraform plan
terraform apply
```


## Rodando terraform localmente
``` shell
## Instalando o python3, pip, awscli
sudo apt install -y python3 python3-pip
sudo pip install awscli

# Baixando e instalando o terraform
wget -P /tmp "https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip"
unzip /tmp/terraform*.zip
sudo mv /tmp/terraform /usr/local/bin/

## Rodando o terraform
git clone https://github.com/aleroxac/linuxtips-terraform
cd linuxtips-terraform
terraform init
terraform plan
terraform apply
```

## To-do
- [x]  aws-ec2-terraform
- [ ]  aws-ecs-terraform
- [ ]  aws-eks-terraform
- [ ]  aws-vpc-terraform