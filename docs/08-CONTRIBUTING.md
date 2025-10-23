← [Previous: Summary](07-SUMMARY.md) | [Documentation Index](00-INDEX.md) | [Home](../README.md) | [Next: Changelog →](09-CHANGELOG.md)

---

# Contributing to Context-Aware Dotfiles

Thank you for considering contributing to this dotfiles project! This document provides guidelines for contributing.

## 🤝 How to Contribute

### Reporting Issues

If you encounter any issues or have suggestions:

1. Check if the issue already exists in the [Issues](https://github.com/YOUR_USERNAME/dotfiles/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Detailed description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, shell version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:

1. Check existing issues and pull requests first
2. Create a detailed issue describing:
   - The enhancement and its benefits
   - Potential implementation approach
   - Any potential drawbacks or considerations

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git
   cd dotfiles
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test your changes**
   ```bash
   ./test.sh
   ```

5. **Commit with descriptive messages**
   ```bash
   git commit -m "Add feature: description of what you added"
   ```

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📝 Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include error handling with `set -e`
- Add comments for complex sections
- Use descriptive variable names
- Follow existing color coding patterns
- Include help/usage information

### Documentation

- Use clear, concise language
- Include code examples where appropriate
- Update README.md for major changes
- Keep documentation in sync with code

### Git Commits

Use conventional commit messages:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

Examples:
```
feat: add support for multiple Git contexts
fix: resolve SSH key loading issue in WSL
docs: update installation instructions
```

## 🧪 Testing

Before submitting a PR:

1. Test on a fresh environment if possible
2. Run the test script: `./test.sh`
3. Verify all critical functionality works
4. Document any new dependencies

## 🎯 Areas for Contribution

Looking for ideas? Consider:

- **New features**: Additional contexts, tools, integrations
- **Bug fixes**: Check open issues
- **Documentation**: Improve guides, add examples
- **Platform support**: Test and improve for different systems
- **Performance**: Optimize scripts and configurations
- **Tools**: Add new modern CLI tools or configurations

## ❓ Questions?

Feel free to:
- Open an issue for discussion
- Reach out via [contact method]

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for making this project better! 🎉
