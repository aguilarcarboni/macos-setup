#!/bin/bash

# This script is used to install the user's necesary software for macOS.

set -e
set -o pipefail

# Get 'server' and 'developer' from positional arguments, or default to null
server="${1:-}"
developer="${2:-}"

if [[ -z "$server" || -z "$developer" ]]; then
    echo "Error: Both 'server' and 'developer' arguments must be provided."
    echo "Usage: $0 <server> <developer>"
    exit 1
fi

###############################################################################
# Install Essential Software
###############################################################################

echo "Installing essential software..."

# Download Xcode CLI tools
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
fi

# Download Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update and upgrade Homebrew
brew update
brew upgrade

# Install essential packages
brew install git btop nmap cmatrix fastfetch neovim gnupg

# Install server packages
if [[ -z "${server}" || "${server}" =~ ^[Yy]$ ]]; then

    # Install VirtualBox
    brew install --cask virtualbox

    # Make Developer directories
    mkdir -p ~/Developer/Virtual\ Machines/Disk\ Images
    mkdir -p ~/Developer/Virtual\ Machines/Home\ Assistant
    mkdir -p ~/Developer/Scripts

    # TODO: Install Home Assistant
    
    exit 0
fi

# Install Python
brew install pyenv pyenv-virtualenv
pyenv install --skip-existing 3.11.9
pyenv global 3.11.9

# Install developer packages
if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then

    # Make Developer directories
    mkdir -p ~/Developer/Repositories
    mkdir -p ~/Developer/Virtual\ Machines/Disk\ Images
    mkdir -p ~/Developer/Scripts

    # Install Google Cloud SDK
    brew install google-cloud-sdk
    
    # Download and install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # in lieu of restarting the shell
    \. "$HOME/.nvm/nvm.sh"

    # Download and install Node.js
    nvm install 22

    # Verify the Node.js version
    node -v
    nvm current
    npm -v
    
    # Install yarn
    npm install --global yarn
fi

###############################################################################
# Get Dotfiles
###############################################################################

read -p "Do you want to get dotfiles? (Y/n): " dotfiles
if [[ -z "${dotfiles}" || "${dotfiles}" =~ ^[Yy]$ ]]; then
    sh utils/get-dotfiles.sh
fi

###############################################################################
# Generate SSH key for Github                                   
###############################################################################

read -p "Do you want to generate an SSH key for Github? (Y/n): " ssh_key
if [[ -z "${ssh_key}" || "${ssh_key}" =~ ^[Yy]$ ]]; then
    ssh-keygen -t ecdsa -b 521 -C "aguilarcarboni@gmail.com"
    cat ~/.ssh/id_ecdsa.pub
    read -sp "Please make sure you have copied this SSH key and will add it to Github." key_confirmation
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain ~/.ssh/id_ecdsa
fi

###############################################################################
# Install Essential Applications
###############################################################################

# Install mas
brew install mas

# ChatGPT
brew install --cask chatgpt

# Notion
brew install --cask notion

# Obsidian
brew install --cask obsidian

# Collections
mas install 1568395334

# WhatsApp
mas install 310633997

# Wipr
mas install 1662217862

# Amazon Q
brew install --cask amazon-q

###############################################################################
# Install Optional Applications
###############################################################################

# Smart Comic
read -p "Do you want to install Smart Comic? (Y/n): " simple_comic
if [[ -z "${simple_comic}" || "${simple_comic}" =~ ^[Yy]$ ]]; then
    mas install 1511175212
fi

# Swiptv
read -p "Do you want to install Swiptv? (Y/n): " swiptv
if [[ -z "${swiptv}" || "${swiptv}" =~ ^[Yy]$ ]]; then
    mas install 1658538188
fi

# Figma
read -p "Do you want to install Figma? (Y/n): " figma
if [[ -z "${figma}" || "${figma}" =~ ^[Yy]$ ]]; then
    brew install --cask figma
fi

# Office tools
read -p "Do you want to install Office tools? (Y/n): " office_tools
if [[ -z "${office_tools}" || "${office_tools}" =~ ^[Yy]$ ]]; then

    # Pages
    mas install 409201541
    
    # Numbers
    mas install 409203825
    
    # Keynote
    mas install 409183694
    
fi

###############################################################################
# Install Essential Developer Tools                                                     
###############################################################################

if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then

    # Watchman
    brew install watchman

    # Windsurf
    brew install --cask windsurf
    
    # Xcode
    mas install 497799835

    # Select Xcode Version
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    
fi

###############################################################################
# Install Optional Developer Tools
###############################################################################

if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then

    # ollama
    read -p "Install ollama? (Y/n): " ollama
    if [[ -z "${ollama}" || "${ollama}" =~ ^[Yy]$ ]]; then
        brew install ollama
    fi

    # Docker
    read -p "Install Docker? (Y/n): " docker
    if [[ -z "${docker}" || "${docker}" =~ ^[Yy]$ ]]; then
        brew install --cask docker
    fi

    # UTM
    read -p "Install UTM? (Y/n): " utm
    if [[ -z "${utm}" || "${utm}" =~ ^[Yy]$ ]]; then
        brew install --cask utm
    fi
    
    # Github
    read -p "Install Github? (Y/n): " github
    if [[ -z "${github}" || "${github}" =~ ^[Yy]$ ]]; then
        brew install --cask github
    fi

    # SF Symbols
    read -p "Install SF Symbols? (Y/n): " sf_symbols
    if [[ -z "${sf_symbols}" || "${sf_symbols}" =~ ^[Yy]$ ]]; then
        brew install --cask sf-symbols
    fi

fi

echo "Successfully installed software."
exit 0