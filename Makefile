.PHONY: help install update test uninstall backup clean configure

# Default target
help:
	@echo "Dotfiles Management Commands:"
	@echo ""
	@echo "  make install    - Install dotfiles and setup environment"
	@echo "  make configure  - Configure Git and SSH settings interactively"
	@echo "  make update     - Update dotfiles and dependencies"
	@echo "  make test       - Run tests to verify installation"
	@echo "  make uninstall  - Remove dotfiles and restore backups"
	@echo "  make backup     - Create backup of current configuration"
	@echo "  make clean      - Clean backup files"
	@echo ""

install:
	@echo "🚀 Installing dotfiles..."
	@bash install.sh

configure:
	@echo "⚙️  Configuring dotfiles..."
	@bash configure.sh

update:
	@echo "🔄 Updating dotfiles..."
	@bash update.sh

test:
	@echo "🧪 Running tests..."
	@bash test.sh

uninstall:
	@echo "🗑️  Uninstalling dotfiles..."
	@bash uninstall.sh

backup:
	@echo "💾 Creating backup..."
	@mkdir -p backup
	@for file in .zshrc .gitconfig .gitconfig.work .gitconfig.personal .zsh_aliases .zsh_functions; do \
		if [ -f "$$HOME/$$file" ]; then \
			cp "$$HOME/$$file" "backup/$$file.$(shell date +%Y%m%d-%H%M%S)"; \
			echo "✓ Backed up $$file"; \
		fi \
	done
	@echo "✓ Backup complete"

clean:
	@echo "🧹 Cleaning backup files..."
	@rm -rf backup/*
	@echo "✓ Backup files cleaned"
