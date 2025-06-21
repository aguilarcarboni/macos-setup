# macOS Setup Automation

This is my personal macOS setup automation script that I use to configure new machines exactly how I like them. It installs all the software I need, configures my preferred system settings, and sets up my development environment automatically.

**Note**: This main branch contains my personal setup with all my specific preferences, applications, and configurations. If you're looking for a more generic setup script that you can easily customize for your own needs, check out the `general` branch which provides a more universal approach.

This script supports both my regular developer machines and my home server setup, with special provisions for my Home Assistant server configuration.

## Features

### 🖥️ Machine Types
- **Developer Machine**: My full development environment with all the IDEs, programming languages, and tools I use
- **Server Machine**: Optimized for my home server with Home Assistant VM setup and minimal GUI applications
- **Regular Machine**: My standard user setup with all the essential applications I use daily

### 🔧 System Configuration
- **Power Management**: Optimized sleep and power settings based on machine type
- **Sharing Services**: Configurable screen sharing, SSH, and file sharing
- **Regional Settings**: Language, measurement units, date/time formats
- **Security Settings**: SSH key generation and GPG setup

### 📱 Software Installation

#### Essential Applications (My Daily Tools)
- ChatGPT
- Notion
- Obsidian
- WhatsApp
- Collections
- Wipr (ad blocker)
- Amazon Q

#### Developer Tools (My Development Stack)
- Xcode and Command Line Tools
- Windsurf IDE (my preferred editor)
- Docker (optional)
- Ollama (optional)
- Watchman

#### Development Environment
- **Languages**: Python (via pyenv), Node.js (via nvm)
- **Package Managers**: Homebrew, npm, yarn
- **Version Control**: Git with SSH key setup
- **Cloud Tools**: Google Cloud SDK
- **Command Line Tools**: btop, nmap, cmatrix, fastfetch, neovim

### 🏠 Home Assistant Server Setup
For server machines, the script automatically:
- Downloads and configures Home Assistant OS virtual machine
- Sets up VirtualBox with optimized VM settings
- Creates launch agents for automatic startup
- Configures network bridging for VM accessibility

### 📄 My Dotfiles Management
- Clones my personal dotfiles from my GitHub repository
- Decrypts and installs my encrypted configuration files
- Sets up my shell configurations (zsh, bash)
- Configures my Git, SSH, GPG, and PyPI settings with my personal credentials

## Usage

**Important**: This is my personal setup script. If you want to use it, you'll need to fork it and modify the dotfiles repository URL, email addresses, and other personal settings to match your preferences. For a more generic starting point, check out the `general` branch.

### Quick Start (For Me)
```bash
git clone <repository-url>
cd macos-setup
chmod +x macos-setup.sh
./macos-setup.sh
```

### Interactive Setup
The script will prompt you for:
1. **Machine Type**: Server or regular machine
2. **Developer Setup**: Whether to install development tools
3. **Optional Software**: Various applications and tools
4. **Dotfiles**: Whether to fetch and install personal dotfiles
5. **SSH Key**: GitHub SSH key generation

## Project Structure

```
macos-setup/
├── macos-setup.sh          # Main setup script
├── dialog/                 # User interaction utilities
│   ├── settings.icns       # Icon for dialogs
│   └── user-dialog.sh      # Dialog helper functions
├── general/                # Core setup scripts
│   ├── ensure-settings.sh  # Settings verification
│   ├── install-software.sh # Software installation
│   ├── modify-settings.sh  # System configuration
│   └── open-apps.sh        # Application launcher
├── server/                 # Home Assistant server setup
│   ├── install-hass.sh     # HA installation script
│   └── start-hass/         # Launch agent configuration
└── utils/                  # Utility scripts
    └── get-dotfiles.sh     # Dotfiles management
```

## Requirements

- macOS (tested on recent versions)
- Administrator privileges
- Internet connection
- GitHub account (for SSH key setup and dotfiles)

## Configuration

### Server Mode
When running in server mode, the script:
- Enables screen sharing, SSH, and file sharing
- Optimizes power settings for always-on operation
- Installs VirtualBox and Home Assistant
- Configures automatic VM startup
- Skips GUI applications and development tools

### Developer Mode
Developer mode includes:
- Full development environment setup
- IDE and editor installation
- Programming language runtimes
- Cloud development tools
- Directory structure for projects

## Customization

### Modifying Software Lists
Edit `general/install-software.sh` to:
- Add/remove applications from the essential list
- Modify optional software prompts
- Update version numbers and download URLs

### System Settings
Customize `general/modify-settings.sh` to:
- Add new system preferences
- Modify power management settings
- Configure additional sharing services

### Using This Script for Your Own Setup
If you want to adapt this script for your own use:

1. **Fork this repository** and switch to the `general` branch for a more generic starting point
2. **Update the dotfiles repository** in `utils/get-dotfiles.sh`:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   ```
3. **Modify email addresses** in the SSH key generation section
4. **Customize software lists** to match your preferences
5. **Update system settings** to your liking

The current main branch is specifically configured for my personal setup with my email (aguilarcarboni@gmail.com) and my dotfiles repository.

## Security Notes

- The script requires administrator privileges for system modifications
- SSH keys are generated with ECDSA 521-bit encryption
- Dotfiles are encrypted and require a passphrase for decryption
- GPG keys are properly configured with correct permissions

## Troubleshooting

### Common Issues
1. **Xcode CLI Tools**: If installation fails, manually run `xcode-select --install`
2. **Homebrew**: Check internet connection if Homebrew installation fails
3. **Virtual Machine**: Ensure VirtualBox is properly installed before HA setup
4. **SSH Keys**: Make sure to add the generated key to your GitHub account

### Logs
The script provides verbose output for debugging. Check terminal output for specific error messages and installation progress.

## Contributing

While this is my personal setup script, feel free to submit issues if you find bugs or have suggestions for improvements. If you're using this as a base for your own setup:

1. Consider working from the `general` branch as a starting point
2. Test changes on a clean macOS installation
3. Update documentation for new features
4. Follow existing script conventions and error handling

## License

This project is my personal macOS setup automation. Feel free to fork and adapt it for your own needs, but remember to update all the personal settings, email addresses, and repository URLs to match your own preferences.
