#!/bin/bash

# Quick Setup Script
# Fast track installation for experienced users

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
║                                                               ║
║           Context-Aware Development Environment              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo -e "\n${CYAN}Quick Setup - Let's get you started in 3 steps!${NC}\n"

# Step 1
echo -e "${BLUE}[1/3]${NC} ${YELLOW}Running bootstrap installation...${NC}"
sleep 1
if [[ -f "./bootstrap.sh" ]]; then
    bash ./bootstrap.sh
else
    echo -e "${GREEN}✓${NC} Bootstrap completed (running from installed location)"
fi

# Step 2
echo -e "\n${BLUE}[2/3]${NC} ${YELLOW}Configuring Git and SSH...${NC}"
sleep 1
if [[ -f "./configure.sh" ]]; then
    bash ./configure.sh
else
    bash ~/.dotfiles/configure.sh
fi

# Step 3
echo -e "\n${BLUE}[3/3]${NC} ${YELLOW}Running verification tests...${NC}"
sleep 1
if [[ -f "./test.sh" ]]; then
    bash ./test.sh
else
    bash ~/.dotfiles/test.sh
fi

# Final message
clear

cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                      ✨ ALL SET! ✨                           ║
║                                                               ║
║   Your context-aware development environment is ready!       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo -e "\n${GREEN}🎉 Installation Complete!${NC}\n"

echo -e "${CYAN}Quick Start:${NC}"
echo -e "  ${YELLOW}cd ~/work${NC}        - Switch to work context"
echo -e "  ${YELLOW}ssh-status${NC}       - Check current context"
echo -e "  ${YELLOW}gclone <url>${NC}     - Clone with auto-context\n"

echo -e "${CYAN}Learn More:${NC}"
echo -e "  ${YELLOW}cat ~/.dotfiles/QUICKSTART.md${NC}  - Quick reference"
echo -e "  ${YELLOW}cat ~/.dotfiles/EXAMPLES.md${NC}    - Usage examples"
echo -e "  ${YELLOW}cat ~/.dotfiles/FAQ.md${NC}         - Common questions\n"

echo -e "${CYAN}Need Help?${NC}"
echo -e "  ${YELLOW}make help${NC}        - Show available commands"
echo -e "  ${YELLOW}ssh-config${NC}       - View SSH configuration\n"

echo -e "${GREEN}Happy coding! 🚀${NC}\n"
