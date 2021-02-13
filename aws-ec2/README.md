## Modo de uso
``` shell
## Using private key from environment variable in ssh-agent
private_key=$(terraform output -raw private_key)
eval $(ssh-agent -s)
ssh-add <(echo "${private_key}")

## Cheking nginx and validate server OS information
server_ip=$(terraform output -raw public_ip)
curl -s ${server_ip}
ssh ubuntu@${server_ip} 'cat /etc/os-release; echo -e "\nsg: $(curl -s http://169.254.169.254/latest/meta-data/security-groups)"'
```