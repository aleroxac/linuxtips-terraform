.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

terraform-install: ## Install Terraform binary
	sudo apt install -y wget unzip
	wget -P /tmp https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
	unzip /tmp/terraform*.zip
	sudo mv terraform /usr/local/bin

docker-install: ## Install Docker and add your user on docker group
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker $${USERNAME}

python-install: ## Install python3, pip3 and install awscli via pip
	sudo apt install -y python3 python3-pip graphviz
	sudo pip install awscli

dot-install: ## Install graphviz with dot commando to use with "terraform graph" command
	sudo apt install -y graphviz



terraform-init: ## Download all necessary terraform plugins
	terraform init

terraform-create-workspace: ## Show correction on terraform scripts syntax  
	terraform workspace new prod

terraform-select-workspace: ## Show correction on terraform scripts syntax  
	terraform workspace select prod



terraform-format: ## Show correction on terraform scripts syntax  
	terraform fmt -check -diff --recursive

terraform-validate: ## Check if all scripts is ok
	terraform validate -json **/*.tf

terraform-plan: ## Show what terraform will create
	terraform plan -out "plan.out"

terraform-apply: ## Create all resources described on terraform scripts
	terraform apply "plan.out"

terraform-graph: ## Show a graph of all resources
	terraform graph | /bin/dot -Tsvg > graph.svg
	xdg-open graph.svg

terraform-list: ## Show a list of all resources
	terraform state list

terraform-plan-destroy: ## Show what terraform will destroy
	terraform plan -destroy -out "plan-destroy.out"

terraform-destroy: ## Destroy all resources
	terraform destroy "plan-destroy.out"



server_ip := $(shell terraform output -raw public_ip)

check-server: ## Check server informations
	LC_ALL=pt_BR.UTF-8
	[ ! -f key.pem ] && (terraform output -raw private_key > key.pem; chmod 400 key.pem;) || exit 0
	ssh -i key.pem ubuntu@${server_ip} 'cat /etc/os-release; echo -e "\nsg: $$(curl -s http://169.254.169.254/latest/meta-data/security-groups)"'

check-nginx: ## Make a request on Nginx
	curl -s ${server_ip}
