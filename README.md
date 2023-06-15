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

## Kubernetes setup, etc

- Setup AWS SSO:
  https://www.notion.so/kantata-dev/aws-sso-e0b629d0c86944dd9e5126b403434db3?pvs=4
- Install krew:
  https://krew.sigs.k8s.io/docs/user-guide/setup/install/
- Install kctx and kns:

        kubectl krew install ctx
        kubectl krew install ns
