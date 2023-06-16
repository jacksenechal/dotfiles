# Usage

## Setup and periodic maintenance
```sh
ansible-playbook -l localhost[,otherhost,...] -K dotfiles-base.yaml
```

## Start SSH agent and add key
```sh
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

## Kubernetes setup, etc

- Setup AWS SSO:
  https://www.notion.so/kantata-dev/aws-sso-e0b629d0c86944dd9e5126b403434db3?pvs=4

