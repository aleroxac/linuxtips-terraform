conf ?= .env
include $(conf)
export $(shell sed 's/=.*//' $(conf))

.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# alias terraform="docker run -v $${PWD}:/code -w /code -e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} hashicorp/terraform:light"



## -------------------- Installation commands --------------------
terraform-install: ## Install Terraform binary
	which unzip || sudo apt install -y wget unzip
	which terraform || wget -P /tmp https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip && unzip /tmp/terraform*.zip && sudo mv terraform /usr/local/bin

docker-install: ## Install Docker and add your user on docker group
	which docker || curl -fsSL https://get.docker.com | sh
	getent group docker | grep $${USERNAME} || sudo usermod -aG docker $${USERNAME}

python-install: ## Install python3, pip3 and install awscli via pip
	which pip3 || sudo apt install -y python3 python3-pip
	which aws || sudo pip install awscli

dot-install: ## Install graphviz with dot commando to use with "terraform graph" command
	which /bin/dot || sudo apt install -y graphviz

install: terraform-install python-install dot-install ## Install all dependencies to run terraform locally
	terraform version
	docker --version
	python -version
	aws --version
	/bin/dot -V


## -------------------- Terraform commands --------------------
init: ## Download all necessary terraform plugins
	# [ ${DOCKER} == 1 ] && alias terraform="docker run -v $${PWD}:/code -w /code -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} hashicorp/terraform:light"
	terraform init

create-workspace: ## Create a terraformworkspace
	terraform workspace new ${ENV}

select-workspace: ## Select a terraform workspace
	terraform workspace select ${ENV}

format: ## Show correction on terraform scripts syntax  
# terraform fmt -check -diff --recursive
	terraform fmt --recursive

validate: ## Check if all scripts is ok
	terraform validate -json **/*.tf

plan: format validate ## Show what terraform will create
	terraform plan -out "plan.out"

apply: ## Create all resources described on terraform scripts
	terraform apply "plan.out"

graph: ## Show a graph of all resources
	terraform graph | /usr/bin/dot -Tsvg > svg/graph.svg
	xdg-open svg/graph.svg

list: ## Show a list of all resources
	terraform state list

show: list ## Show all create resources
	terraform output
	terraform show

plan-destroy: ## Show what terraform will destroy
	terraform plan -destroy -out "plan-destroy.out"

destroy: plan-destroy ## Destroy all resources
	terraform destroy -auto-approve





## -------------------- Docker & ECR --------------------
ecr_repo := $(shell terraform output -raw ecr_repo)

login: ## Athenticate on ECR
	aws ecr get-login-password --region us-east-1 | xargs -I xxx docker login -u AWS -p  xxx https://$(ecr_repo)

pull: ## Pull nginx image
	docker pull nginx:latest

tag: ## Create a image tag 
	docker tag nginx:latest $(ecr_repo):latest

push: login pull tag ## Push the nginx image to ECR
	docker push $(ecr_repo):latest



## -------------------- Main --------------------
# server_ip := $(shell terraform output -raw public_ip)
fqdn := $(shell terraform output -raw fqdn)

check-server: ## Check server informations
	[ ! -f key.pem ] && (terraform output -raw private_key > key.pem; chmod 400 key.pem;) || exit 0
	ssh -i key.pem ubuntu@${server_ip} 'cat /etc/os-release; echo -e "\nsg: $$(curl -s http://169.254.169.254/latest/meta-data/security-groups)"'

check-nginx: ## Make a request on Nginx
	terraform output | grep -q fqdn && curl $$(terraform output -raw fqdn) 2> /dev/null 2> /dev/null || curl $$(terraform output -raw public_ip) > /dev/null 2> /dev/null

clean: # Remove files generated during Terraform scripts execution 
	rm -fv *.{out,pem,svg}