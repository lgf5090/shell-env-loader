# 🚀 Shell-Env-Loader Installation Guide

Cross-shell environment variable management made simple! Install once, use everywhere.

## 📦 Quick Installation (Recommended)

### One-Command Installation from GitHub

```bash
# Install for all available shells (recommended)
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash

# Or install for specific shells
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- bash zsh

# Or install for all shells non-interactively
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --all
```

### Alternative: Download and Install Manually

```bash
# Download the repository
git clone https://github.com/lgf5090/shell-env-loader.git
cd shell-env-loader

# Install for all available shells
./install.sh --all

# Or install for specific shells
./install.sh bash zsh fish

# Or check what shells are available first
./install.sh --list
```

## 🐚 Supported Shells

| Shell | Status | Features |
|-------|--------|----------|
| **Bash** | ✅ 100% | Full compatibility, advanced features |
| **Zsh** | ✅ 96.4% | Native Zsh integration, Oh My Zsh compatible |
| **Fish** | ✅ 100% | Modern syntax, user-friendly |
| **Nushell** | ✅ 100% | Structured data, powerful scripting |
| **PowerShell** | ✅ 98.75% | Cross-platform, Windows native |

## 🔧 Installation Options

### Interactive Installation
```bash
curl -fsSL https://raw.githubusercontent.com/your-username/shell-env-loader/main/install-github.sh | bash
```
- Detects available shells automatically
- Provides installation options menu
- User-friendly prompts

### Non-Interactive Installation
```bash
# Install for all shells
curl -fsSL https://raw.githubusercontent.com/your-username/shell-env-loader/main/install-github.sh | bash -s -- --all

# Install for specific shells
curl -fsSL https://raw.githubusercontent.com/your-username/shell-env-loader/main/install-github.sh | bash -s -- --shells bash zsh fish
```

### Local Installation
```bash
# Clone and install
git clone https://github.com/your-username/shell-env-loader.git
cd shell-env-loader

# Check system compatibility
./install.sh --check

# List available shells
./install.sh --list

# Install with options
./install.sh --all                    # All shells
./install.sh bash zsh                 # Specific shells
./install.sh --dry-run bash           # Test mode
./install.sh --force bash             # Force reinstall
```

## 📋 Installation Process

The installer will:

1. **🔍 Detect** available shells on your system
2. **📥 Download** necessary files (if installing from GitHub)
3. **🛡️ Backup** existing configuration files
4. **📁 Install** shell-specific loaders to `~/.local/share/env-loader/`
5. **⚙️ Configure** shell startup files (`.bashrc`, `.zshrc`, etc.)
6. **✅ Validate** installation integrity
7. **🔄 Rollback** automatically if any step fails

## 🗂️ Installation Locations

```
~/.local/share/env-loader/
├── bash/           # Bash-specific files
├── zsh/            # Zsh-specific files  
├── fish/           # Fish-specific files
├── nu/             # Nushell-specific files
├── pwsh/           # PowerShell-specific files
├── common/         # Shared utilities
└── backups/        # Configuration backups
```

## 🔧 Advanced Options

### Validation and Testing
```bash
# Validate existing installations
./install.sh --validate

# Validate specific shells
./install.sh --validate bash zsh

# Test installation without changes
./install.sh --dry-run --all
```

### Troubleshooting
```bash
# Check system compatibility
./install.sh --check

# Force reinstallation
./install.sh --force bash

# View installation logs
tail -f /tmp/env-loader-install.log
```

### Uninstallation
```bash
# Uninstall from specific shells
./install.sh --uninstall bash zsh

# Uninstall from all shells
./install.sh --uninstall --all
```

## 🚨 Prerequisites

### Required
- **Unix-like system** (Linux, macOS, WSL)
- **One of**: `curl` or `wget` (for GitHub installation)
- **Basic commands**: `cp`, `mkdir`, `chmod`
- **Write access** to `~/.local/share/` and shell config files

### Recommended
- **Modern shell versions**:
  - Bash 4.0+
  - Zsh 5.0+
  - Fish 3.0+
  - Nushell 0.60+
  - PowerShell 7.0+

## 🛡️ Safety Features

- **🔄 Automatic backups** of configuration files
- **✅ Installation validation** with integrity checks
- **🔙 Automatic rollback** on installation failures
- **📝 Comprehensive logging** for troubleshooting
- **🧪 Dry-run mode** for safe testing

## 🎯 Quick Start After Installation

1. **Restart your shell** or run:
   ```bash
   source ~/.bashrc    # For Bash
   source ~/.zshrc     # For Zsh
   # Fish and Nushell restart automatically
   ```

2. **Create a `.env` file** in your project:
   ```bash
   echo "API_KEY=your_secret_key" > .env
   echo "DATABASE_URL=postgresql://localhost:5432/mydb" >> .env
   ```

3. **Navigate to your project** and variables load automatically:
   ```bash
   cd /path/to/your/project
   echo $API_KEY  # Shows: your_secret_key
   ```

## 🆘 Getting Help

- **Installation issues**: Check `/tmp/env-loader-install.log`
- **Runtime issues**: Use `show_env_status` command
- **GitHub Issues**: [Report bugs and feature requests](https://github.com/your-username/shell-env-loader/issues)
- **Documentation**: [Full documentation](https://github.com/your-username/shell-env-loader/wiki)

## 🎉 Success!

After installation, you'll have powerful cross-shell environment variable management that:
- ✅ Works across all your shells
- ✅ Loads `.env` files automatically
- ✅ Supports shell and platform-specific variables
- ✅ Handles complex quoting and Unicode
- ✅ Provides hierarchy-based configuration

**Happy coding!** 🚀
