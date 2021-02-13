.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


## -------------------- Installation commands --------------------
terraform-install: ## Install Terraform binary
	sudo apt install -y wget unzip
	wget -P /tmp https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
	unzip /tmp/terraform*.zip
	sudo mv terraform /usr/local/bin

docker-install: ## Install Docker and add your user on docker group
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker $${USERNAME}

python-install: ## Install python3, pip3 and install awscli via pip
	sudo apt install -y python3 python3-pip
	sudo pip install awscli

dot-install: ## Install graphviz with dot commando to use with "terraform graph" command
	sudo apt install -y graphviz



## -------------------- Terraform commands --------------------
terraform-init: ## Download all necessary terraform plugins
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light init

terraform-create-workspace: ## Show correction on terraform scripts syntax
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light workspace new prod

terraform-select-workspace: ## Show correction on terraform scripts syntax  
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light workspace select prod

terraform-format: ## Show correction on terraform scripts syntax  
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light fmt -check -diff --recursive

terraform-validate: ## Check if all scripts is ok
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light validate -json **/*.tf

terraform-plan: ## Show what terraform will create
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light plan -out "plan.out"

terraform-apply: ## Create all resources described on terraform scripts
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light apply "plan.out"

terraform-graph: ## Show a graph of all resources
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light graph | /bin/dot -Tsvg > graph.svg
	xdg-open graph.svg

terraform-list: ## Show a list of all resources
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light state list

terraform-plan-destroy: ## Show what terraform will destroy
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light plan -destroy -out "plan-destroy.out"

terraform-destroy: ## Destroy all resources
	docker run --rm -v $$PWD:/code -w /code \
		-e AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} \
		hashicorp/terraform:light destroy -auto-approve



## -------------------- Main --------------------
server_ip := $(shell terraform output -raw public_ip)

check-server: ## Check server informations
	[ ! -f key.pem ] && (terraform output -raw private_key > key.pem; chmod 400 key.pem;) || exit 0
	ssh -i key.pem ubuntu@${server_ip} 'cat /etc/os-release; echo -e "\nsg: $$(curl -s http://169.254.169.254/latest/meta-data/security-groups)"'

check-nginx: ## Make a request on Nginx
	curl -s ${server_ip}

clean:
	rm -fv *.{out,pem,svg}