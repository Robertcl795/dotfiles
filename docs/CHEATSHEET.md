# Dotfiles Quick Reference

## Installation & Updates

```bash
# Fresh install (wget)
wget -qO- https://raw.githubusercontent.com/YOURUSERNAME/dotfiles/main/bootstrap.sh | bash

# Fresh install (curl)
curl -fsSL https://raw.githubusercontent.com/YOURUSERNAME/dotfiles/main/bootstrap.sh | bash

# Manual install
git clone https://github.com/YOURUSERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh

# Update dotfiles
cd ~/.dotfiles && git pull && ./install.sh

# Reload shell
exec zsh
# or
source ~/.zshrc
```

## mise - Version Management

```bash
# Install tools globally
mise use -g node@lts
mise use -g python@3.12
mise use -g rust@latest

# Install tools for current project
mise use node@20.11.0
mise use python@3.11

# List available versions
mise ls-remote node
mise ls-remote python

# List installed versions
mise list

# Show current versions
mise current

# Update all tools
mise upgrade

# Check health
mise doctor

# Prune old versions
mise prune

# Uninstall a version
mise uninstall node@18.0.0
```

## pnpm - Package Management

```bash
# Install dependencies
pnpm install
pnpm i

# Add packages
pnpm add <package>
pnpm add -D <package>          # dev dependency
pnpm add -g <package>          # global

# Workspace commands
pnpm -r <command>              # run in all packages
pnpm --filter <name> <command> # run in specific package
pnpm -w <command>              # run in workspace root

# Update packages
pnpm update
pnpm update --latest           # update to latest
pnpm update --interactive      # interactive update

# Remove packages
pnpm remove <package>

# List packages
pnpm list
pnpm list --depth=0            # top-level only

# Run scripts
pnpm run <script>
pnpm dev                       # if dev script exists
pnpm build                     # if build script exists
```

## Git Aliases

```bash
# Status & basics
gs                             # git status
ga <files>                     # git add
gaa                           # git add --all
gc                            # git commit -v
gcm "message"                 # git commit -m
gp                            # git push
gpl                           # git pull

# Branches
gb                            # git branch
gba                           # git branch -a
gcb <name>                    # git checkout -b (create branch)
gco <name>                    # git checkout
branches                      # list by date
cleanup                       # remove merged branches

# Logs
l                             # log --oneline --graph
la                            # log --all
ll                            # detailed log
gl                            # alias for la

# Advanced
gd                            # git diff
gdc                           # git diff --cached
amend                         # commit --amend --no-edit
undo                          # reset --soft HEAD^
up                            # pull --rebase --autostash
publish                       # push -u origin HEAD
diffm                         # diff with main branch

# Stash
gst                           # git stash
gstp                          # git stash pop
save "message"                # stash with message
stashes                       # list stashes

# Info
current                       # current branch name
changed                       # files in last commit
aliases                       # show all git aliases
```

## Modern CLI Tools

```bash
# eza (ls replacement)
ls                            # eza with icons
ll                            # detailed list
la                            # show all
lt                            # tree view
l                             # detailed list

# bat (cat replacement)
cat <file>                    # syntax highlighted
ccat <file>                   # plain output

# zoxide (smart cd)
z <partial-path>              # jump to directory
zi                            # interactive selection

# fzf (fuzzy finder)
fzf                           # search files
**<TAB>                       # trigger in commands
CTRL+R                        # search history
CTRL+T                        # search files
ALT+C                         # cd to directory

# ripgrep (grep replacement)
grep "pattern"                # recursive search
grep -i "pattern"             # case insensitive

# fd (find replacement)
find <name>                   # search by name
find -e <ext>                 # search by extension
```

## Docker

```bash
# Basics
d                             # docker
dc                            # docker-compose
dps                           # docker ps (formatted)
dimg                          # docker images
dprune                        # clean everything

# Common commands
docker run <image>
docker exec -it <container> bash
docker logs -f <container>
docker stop <container>
docker rm <container>
docker-compose up -d
docker-compose down
```

## Kubernetes (kubectl)

```bash
# Basics
k                             # kubectl
kgp                           # get pods
kgs                           # get services
kgd                           # get deployments

# Logs & exec
kl <pod>                      # logs
kl -f <pod>                   # follow logs
kx <pod> -- bash              # exec into pod

# Info
kd <resource> <name>          # describe
k get all                     # get all resources

# Context
k config get-contexts         # list contexts
k config use-context <name>   # switch context
```

## K3D

```bash
# Create cluster
k3d cluster create dev --agents 2

# Quick create
k3d-create                    # alias for above

# Delete cluster
k3d cluster delete dev
k3d-delete                    # alias for above

# List clusters
k3d cluster list

# Get kubeconfig
k3d kubeconfig get dev
```

## Helm

```bash
# Basics
h                             # helm
hl                            # helm list
hi <name> <chart>             # helm install
hu <name> <chart>             # helm upgrade

# Common commands
helm repo add <name> <url>
helm repo update
helm search repo <keyword>
helm install <name> <chart> --values values.yaml
helm upgrade <name> <chart>
helm uninstall <name>
helm rollback <name> <revision>
```

## direnv

```bash
# Create .envrc in project
echo 'export VAR=value' > .envrc
echo 'use mise' >> .envrc

# Allow file
direnv allow

# Reload
direnv reload

# Deny
direnv deny

# Status
direnv status
```

## Angular (with pnpm)

```bash
# Angular CLI via pnpm
ng                            # pnpm exec ng
ngs                           # ng serve
ngb                           # ng build
ngt                           # ng test
ngg                           # ng generate

# pnpm workspace
p                             # pnpm
pi                            # pnpm install
pa <package>                  # pnpm add
pd                            # pnpm dev
pb                            # pnpm build
pt                            # pnpm test
pl                            # pnpm lint
pf                            # pnpm format

# Workspace specific
pw @org/app <command>         # run in specific package
pr <command>                  # run in all packages
```

## Useful Functions

```bash
# Create and enter directory
mkcd <dirname>

# Extract any archive
extract <file>

# Start HTTP server
serve [port]                  # default 8000

# Kill process by port
killport <port>

# Clone and cd
gcl <repo-url>

# Open Windows Explorer (WSL)
explorer                      # open current dir
```

## Zsh Navigation

```bash
# Directory stack
cd -                          # previous directory
cd -2                         # 2 directories back
dirs -v                       # show directory stack
d                             # alias for dirs -v

# History
CTRL+R                        # search history (fzf)
!!                            # last command
!$                            # last argument
!*                            # all arguments
```

## Completion

```bash
# Trigger completion
<TAB>                         # complete
<TAB><TAB>                    # show all options

# FZF completion
**<TAB>                       # fzf file search
cd **<TAB>                    # fzf directory search
kill -9 **<TAB>               # fzf process search
```

## Configuration Files

```bash
# Main config
~/.zshrc                      # Zsh config
~/.config/starship.toml       # Starship prompt
~/.gitconfig                  # Git config
~/.config/mise/config.toml    # mise config

# Local overrides
~/.zshrc.local                # Local zsh config
.envrc                        # Directory environment
.mise.toml                    # Project mise config
```

## Troubleshooting

```bash
# Slow zsh startup
time zsh -i -c exit           # measure startup time

# Rebuild completions
rm ~/.zcompdump && exec zsh

# Check mise
mise doctor

# Reset zinit
rm -rf ~/.local/share/zinit
exec zsh

# Update all tools
mise upgrade
zinit update --all

# Check PATH
echo $PATH

# Debug zsh
zsh -xv                       # verbose startup
```

## Common Workflows

### Starting a New Angular Project

```bash
# Create workspace
mkdir my-workspace && cd my-workspace

# Setup versions
mise use node@lts
corepack enable
pnpm init

# Setup workspace
echo 'packages:\n  - "apps/*"\n  - "libs/*"' > pnpm-workspace.yaml

# Create Angular app
pnpm create @angular/app apps/shell

# Setup environment
echo 'use mise' > .envrc
direnv allow
```

### Setting Up a New Machine

```bash
# Install dotfiles
wget -qO- https://raw.githubusercontent.com/YOURUSERNAME/dotfiles/main/bootstrap.sh | bash

# Restart shell
exec zsh

# Install Node & pnpm
mise use -g node@lts
corepack enable

# Clone your projects
gcl <repo-url>
cd <project>
pnpm install
```

### Daily Development

```bash
# Morning routine
z project                     # jump to project
git pull                      # update code
pnpm install                  # update deps
pd                            # start dev server

# Working
gs                            # check status
ga .                          # stage changes
gcm "feat: add feature"       # commit
gp                            # push

# Testing
pt                            # run tests
pl                            # lint
pf                            # format
```

---

**Pro tip**: Use `<TAB>` completion everywhere - it's powered by fzf for most commands!
