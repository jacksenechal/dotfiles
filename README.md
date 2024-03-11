# Usage

## Setup and periodic maintenance
```sh
ansible-playbook -l localhost[,otherhost,...] -K dotfiles-base.yaml
```

### Just nvim
```sh
ansible-playbook -l localhost -t nvim -K dotfiles-base.yaml
```

## Start SSH agent and add key
```sh
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

