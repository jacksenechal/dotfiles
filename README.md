# Usage

## Set it up
```sh
ansible-playbook -K dotfiles-base.yaml
```

## Make ZSH your shell (one time only)
```sh
chsh -s $(which zsh)
```

## Start SSH agent and add key
```sh
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

## Regular maintenance

- Periodically update your VIM plugins with `:PlugUpdate`
