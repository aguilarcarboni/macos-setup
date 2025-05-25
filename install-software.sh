# !/bin/bash

# This script is used install the user's necesary software for macOS.

set -e
set -o pipefail

###############################################################################
# Install Essential Software
###############################################################################

echo "Installing essential software..."
read -p "Is this a developer machine? (Y/n): " developer

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
brew install git btop nmap cmatrix fastfetch neovim
brew install gnupg

# Install Python
brew install pyenv pyenv-virtualenv
pyenv install 3.11.9
pyenv global 3.11.9

if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then

    brew install google-cloud-sdk
    
    # Download and install nvm:
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # in lieu of restarting the shell
    \. "$HOME/.nvm/nvm.sh"

    # Download and install Node.js:
    nvm install 22

    # Verify the Node.js version:
    node -v
    nvm current
    npm -v
    
    # Install yarn
    npm install --global yarn
fi

###############################################################################
# Get Dotfiles
###############################################################################

sh get-dotfiles.sh

###############################################################################
# Generate SSH key for Github                                   
###############################################################################

echo "Generating SSH key for Github"
ssh-keygen -t ecdsa -b 521 -C "aguilarcarboni@gmail.com"
cat ~/.ssh/id_ecdsa.pub
read -sp "Please make sure you have copied this SSH key and will add it to Github." key_confirmation

echo "Creating SSH agent to store keychain"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ecdsa

###############################################################################
# Install Essential Applications
###############################################################################

echo "Installing essential apps..."

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

echo "Installing optional apps..."

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
read -p "Do you want to install Office tools? (Y/n): " microsoft
if [[ -z "${microsoft}" || "${microsoft}" =~ ^[Yy]$ ]]; then

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

    echo "Installing essential developer tools..."

    # Watchman
    brew install watchman

    # Windsurf
    if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then
        brew install --cask windsurf
    fi
    
    # Xcode
    mas install 497799835

    # Select Xcode Version
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    
    # Make Repositories directory
    mkdir -p ~/Developer/Repositories

    # Make Virtual Machines directory
    mkdir -p ~/Developer/Virtual\ Machines
    
fi

###############################################################################
# Install Optional Developer Tools
###############################################################################

if [[ -z "${developer}" || "${developer}" =~ ^[Yy]$ ]]; then

    echo "Installing optional developer apps..."

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

###############################################################################
# Install Work Tools
###############################################################################

# Chrome
read -p "Do you want to install Chrome? (Y/n): " chrome
if [[ -z "${chrome}" || "${chrome}" =~ ^[Yy]$ ]]; then
    brew install --cask google-chrome
fi

# Postman
read -p "Do you want to install Postman? (Y/n): " postman
if [[ -z "${postman}" || "${postman}" =~ ^[Yy]$ ]]; then
    brew install --cask postman
fi

# Zoom
read -p "Do you want to install Zoom? (Y/n): " zoom
if [[ -z "${zoom}" || "${zoom}" =~ ^[Yy]$ ]]; then
    brew install -cask zoom
fi

fastfetch

sleep 5

open -a "Amazon Q"
open -a "Wipr"
