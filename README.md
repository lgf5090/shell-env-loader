# 🚀 Shell-Env-Loader

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Support](https://img.shields.io/badge/Shells-Bash%20%7C%20Zsh%20%7C%20Fish%20%7C%20Nu%20%7C%20PowerShell-blue)](https://github.com/lgf5090/shell-env-loader)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-green)](https://github.com/lgf5090/shell-env-loader)

**Cross-shell environment variable management made simple!** 

Automatically load `.env` files across all your favorite shells with intelligent hierarchy, platform detection, and shell-specific variable support.

## ✨ Features

- 🐚 **Universal Shell Support**: Works with Bash, Zsh, Fish, Nushell, and PowerShell
- 📁 **Smart File Discovery**: Automatically finds and loads `.env` files in your project hierarchy
- 🎯 **Intelligent Precedence**: Shell-specific and platform-specific variable support
- 🔒 **Safe & Reliable**: Automatic backups, validation, and rollback on failures
- ⚡ **High Performance**: Optimized for each shell with minimal startup overhead
- 🌍 **Cross-Platform**: Linux, macOS, Windows (WSL), and more

## 🎬 Quick Demo

```bash
# Create a .env file
echo "API_KEY=secret123" > .env
echo "DATABASE_URL=postgresql://localhost:5432/myapp" >> .env

# Navigate to your project (variables load automatically)
cd /path/to/your/project
echo $API_KEY        # Output: secret123
echo $DATABASE_URL   # Output: postgresql://localhost:5432/myapp
```

## 📦 Installation

Choose your preferred installation method:

### 📊 Installation Methods Comparison

| Feature | Online Installation | Local Installation |
|---------|-------------------|-------------------|
| **Speed** | ⚡ Fastest (one command) | 🐌 Slower (clone + install) |
| **Disk Usage** | 💾 Minimal (only installs) | 📁 Full repo (~2MB) |
| **Internet Required** | 🌐 Yes (during install) | 🌐 Yes (for clone only) |
| **Customization** | ❌ Limited | ✅ Full access to source |
| **Updates** | 🔄 Re-run install command | 🔄 `git pull` + reinstall |
| **Development** | ❌ Not suitable | ✅ Perfect for development |
| **CI/CD** | ✅ Ideal for automation | ✅ Good for testing |
| **Offline Use** | ❌ No | ✅ Yes (after clone) |

**💡 Recommendation**: Use **Online Installation** for quick setup and production use. Use **Local Installation** for development, customization, or when you need offline access.

### 🌐 Method 1: Online Installation (Recommended)

**One-command installation** - downloads and installs automatically:

```bash
# Install for all available shells (recommended)
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash
```

**Advanced online installation options:**
```bash
# Install for specific shells
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- bash zsh

# Non-interactive installation (for automation)
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --all

# Check system compatibility before installing
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --check

# List available shells on your system
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --list

# Dry run (test without installing)
curl -fsSL https://raw.githubusercontent.com/lgf5090/shell-env-loader/main/install.sh | bash -s -- --dry-run --all
```

**What happens during online installation:**
1. 🔍 **Auto-detects** your system and available shells
2. 📥 **Downloads** all necessary files from GitHub
3. 🛡️ **Validates** system compatibility and prerequisites
4. 📁 **Installs** shell-specific loaders and configurations
5. ✅ **Verifies** installation integrity
6. 🧹 **Cleans up** temporary files automatically

### 🏠 Method 2: Local Installation

**Clone and install locally** - gives you full control and access to source code:

```bash
# Clone the repository
git clone https://github.com/lgf5090/shell-env-loader.git
cd shell-env-loader

# Install for all available shells
./install.sh --all

# Or install for specific shells
./install.sh bash zsh fish

# Check available options
./install.sh --help
```

**Advanced local installation options:**
```bash
# Check system compatibility
./install.sh --check

# List available shells
./install.sh --list

# Validate existing installations
./install.sh --validate

# Test installation without changes
./install.sh --dry-run --all

# Force reinstall (overwrites existing)
./install.sh --force bash zsh

# Uninstall from specific shells
./install.sh --uninstall bash

# Uninstall from all shells
./install.sh --uninstall --all
```

**Benefits of local installation:**
- 🔧 **Full control** over the installation process
- 📖 **Access to source code** for customization
- 🧪 **Easy testing** and development
- 📝 **Comprehensive documentation** and examples
- 🔄 **Easy updates** with `git pull`

## 🐚 Supported Shells

| Shell | Compatibility | Features |
|-------|---------------|----------|
| **Bash** | ✅ 100% | Full feature support, advanced precedence |
| **Zsh** | ✅ 96.4% | Native integration, Oh My Zsh compatible |
| **Bzsh** | ✅ 100% | Bash/Zsh compatible version for both shells |
| **Fish** | ✅ 100% | Modern syntax, user-friendly |
| **Nushell** | ✅ 100% | Structured data, powerful scripting |
| **PowerShell** | ✅ 98.75% | Cross-platform, Windows native |

### 🔄 Installation Modes

**Shell-Specific Installation:**
- `./install.sh bash` - Installs Bash-optimized version
- `./install.sh zsh` - Installs Zsh-optimized version
- `./install.sh bash zsh` - Installs separate optimized versions for each

**Unified Installation:**
- `./install.sh bzsh` - Installs single compatible version for both Bash and Zsh
- Ideal for users who switch between Bash and Zsh frequently
- Uses shared configuration and maintains consistency

## 🔧 Installation Options

### Basic Installation
```bash
./install.sh --all                    # Install for all available shells
./install.sh bash zsh                 # Install shell-specific versions for Bash and Zsh
./install.sh bzsh                     # Install Bash/Zsh compatible version for both shells
./install.sh --list                   # List available shells on your system
```

### Advanced Options
```bash
./install.sh --check                  # Check system compatibility
./install.sh --validate               # Validate existing installations
./install.sh --dry-run bash           # Test installation without changes
./install.sh --force bash             # Force reinstall
./install.sh --uninstall bash         # Uninstall from specific shell
```

## 🚀 Quick Start

1. **Install shell-env-loader** (see installation methods above)

2. **Restart your shell** or reload configuration:
   ```bash
   source ~/.bashrc    # For Bash
   source ~/.zshrc     # For Zsh
   # Fish and Nushell restart automatically
   ```

3. **Create a `.env` file** in your project:
   ```bash
   # Example .env file
   API_KEY=your_secret_key
   DATABASE_URL=postgresql://localhost:5432/mydb
   NODE_ENV=development
   DEBUG=true
   ```

4. **Navigate to your project** - variables load automatically:
   ```bash
   cd /path/to/your/project
   echo $API_KEY  # Shows: your_secret_key
   ```

## 📁 File Hierarchy & Precedence

Shell-env-loader searches for `.env` files in this order (highest precedence first):

```
1. ./env                          # Current directory (precedence: 100)
2. ~/.cfgs/.env                   # User config directory (precedence: 50)  
3. ~/.env                         # User home directory (precedence: 10)
```

### Shell-Specific Variables

Variables can be targeted to specific shells:

```bash
# .env file
API_KEY=general_key                    # All shells
API_KEY_BASH=bash_specific_key         # Only in Bash
API_KEY_ZSH=zsh_specific_key          # Only in Zsh
API_KEY_FISH=fish_specific_key        # Only in Fish
API_KEY_NU=nushell_specific_key       # Only in Nushell
API_KEY_PS=powershell_specific_key    # Only in PowerShell
```

### Platform-Specific Variables

Variables can be targeted to specific platforms:

```bash
# .env file
DATABASE_URL=default_url               # All platforms
DATABASE_URL_LINUX=linux_url          # Only on Linux
DATABASE_URL_MACOS=macos_url          # Only on macOS
DATABASE_URL_WIN=windows_url          # Only on Windows
DATABASE_URL_WSL=wsl_url              # Only on WSL
```

## 🎯 Advanced Features

### Variable Expansion
```bash
# Tilde expansion
HOME_PROJECT=~/my-project              # Expands to /home/user/my-project

# Variable references
BASE_URL=https://api.example.com
API_ENDPOINT=${BASE_URL}/v1            # Expands to https://api.example.com/v1
```

### Complex Values
```bash
# Quoted strings with spaces
MESSAGE="Hello, World!"

# JSON configuration
CONFIG='{"debug": true, "port": 3000}'

# Multi-line values
SQL_QUERY="SELECT * FROM users 
WHERE active = true 
ORDER BY created_at DESC"
```

### Unicode Support
```bash
# International characters
WELCOME_MESSAGE="欢迎 Welcome Bienvenido"
EMOJI_STATUS="✅ Ready to go! 🚀"
```

## 🛠️ Management Commands

After installation, use these commands to manage your environment:

```bash
show_env_status          # Show current environment status
reload_env               # Reload environment variables
list_env_files          # List all .env files in hierarchy
validate_env_syntax     # Validate .env file syntax
```

## 📂 Installation Structure

Files are installed to `~/.local/share/env-loader/`:

```
~/.local/share/env-loader/
├── bash/               # Bash-specific files
├── zsh/                # Zsh-specific files
├── fish/               # Fish-specific files
├── nu/                 # Nushell-specific files
├── pwsh/               # PowerShell-specific files
├── common/             # Shared utilities
└── backups/            # Configuration backups
```

## 🔒 Safety Features

- **🔄 Automatic Backups**: Configuration files are backed up before modification
- **✅ Installation Validation**: Comprehensive checks ensure proper installation
- **🔙 Automatic Rollback**: Failed installations are automatically reverted
- **📝 Comprehensive Logging**: Detailed logs for troubleshooting
- **🧪 Dry-Run Mode**: Test installations without making changes

## 🆘 Troubleshooting

### Common Issues

**Installation fails:**
```bash
# Check system compatibility
./install.sh --check

# View installation logs
tail -f /tmp/env-loader-install.log

# Force reinstall
./install.sh --force bash
```

**Variables not loading:**
```bash
# Check environment status
show_env_status

# Validate .env file syntax
validate_env_syntax

# Reload environment manually
reload_env
```

**Shell-specific issues:**
```bash
# Validate specific shell installation
./install.sh --validate bash

# Reinstall for specific shell
./install.sh --force bash
```

### Getting Help

- 📖 **Documentation**: [Full documentation](https://github.com/lgf5090/shell-env-loader/wiki)
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/lgf5090/shell-env-loader/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/lgf5090/shell-env-loader/discussions)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to all shell maintainers for creating amazing shells
- Inspired by various dotenv implementations across different languages
- Built with ❤️ for the developer community

---

**Made with ❤️ by the shell-env-loader team**

⭐ **Star this repo if you find it useful!** ⭐
