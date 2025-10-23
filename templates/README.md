# Templates Directory

This directory contains template files that are used during the installation process.

## 📄 Files

### Environment Files (direnv)

- **`.envrc.work`** - Environment configuration for work context
  - Loaded automatically when entering `~/work` directory
  - Sets `SSH_AUTH_SOCK_CONTEXT=work`
  - Loads work SSH key
  - Sets Git SSH command for work

- **`.envrc.personal`** - Environment configuration for personal context
  - Loaded automatically when entering `~/personal` directory
  - Sets `SSH_AUTH_SOCK_CONTEXT=personal`
  - Loads personal SSH key
  - Sets Git SSH command for personal

### SSH Configuration Files

- **`ssh-config.main`** - Main SSH configuration
  - Includes work and personal SSH configs
  - Sets default SSH options

- **`ssh-config.work`** - Work SSH hosts configuration
  - GitHub work host alias (`github.com-work`)
  - GitLab work host alias (optional)
  - Bitbucket work host alias (optional)
  - Company Git servers (add as needed)

- **`ssh-config.personal`** - Personal SSH hosts configuration
  - GitHub personal host alias (`github.com-personal`)
  - GitLab personal host alias (optional)
  - Bitbucket personal host alias (optional)

## 🔄 Usage

These templates are copied to their target locations during installation:

```
Template File              →  Target Location
─────────────────────────────────────────────────────
.envrc.work               →  ~/work/.envrc
.envrc.personal           →  ~/personal/.envrc
ssh-config.main           →  ~/.ssh/config
ssh-config.work           →  ~/.ssh/config.work
ssh-config.personal       →  ~/.ssh/config.personal
```

## ✏️ Customization

You can modify these templates before installation or edit the installed files directly:

### Adding More Git Providers

Edit `ssh-config.work` or `ssh-config.personal` to add more Git providers:

```ssh
Host gitlab.company.com
    HostName gitlab.company.com
    User git
    IdentityFile ~/.ssh/keys/work/id_ed25519
    IdentitiesOnly yes
```

### Adding Environment Variables

Edit `.envrc.work` or `.envrc.personal` to add context-specific environment variables:

```bash
# AWS Profile
export AWS_PROFILE="work"

# Kubernetes Config
export KUBECONFIG="$HOME/.kube/config-work"

# NPM Token
export NPM_TOKEN="your-work-npm-token"
```

### Adding More Contexts

To add a new context (e.g., `freelance`):

1. Copy `.envrc.work` to `.envrc.freelance`
2. Copy `ssh-config.work` to `ssh-config.freelance`
3. Update the context name and paths
4. Create `~/freelance` directory
5. Copy the files during installation

## 🔒 Security Notes

- Never commit SSH private keys to version control
- The `.envrc` files are safe to commit (they reference key paths, not keys themselves)
- SSH config files are safe to commit (they contain host aliases, not credentials)
- Keep your SSH keys secure with proper file permissions (600)

## 📚 Related Documentation

- [IMPLEMENTATION.md](../IMPLEMENTATION.md) - Full setup guide
- [QUICKSTART.md](../QUICKSTART.md) - Quick reference
- [FAQ.md](../FAQ.md) - Common questions
