#!/bin/bash

# This script is used to get the dotfiles from Github and install them on the user's machine.
# WARNING: THIS IS A DESTRUCTIVE SCRIPT. IT WILL OVERWRITE THE USER'S EXISTING DOTFILES.

set -e
set -o pipefail

###############################################################################
# Get Dotfiles
###############################################################################

echo "Cloning dotfiles from Github..."
git clone https://github.com/aguilarcarboni/dotfiles.git ~/dotfiles

echo "Decrypting dotfiles..."
read -sp "Enter your passphrase to decrypt your files: " passphrase
gpg --batch --passphrase ${passphrase} --decrypt ~/dotfiles/encrypted.tar.gz.gpg > ~/dotfiles/encrypted.tar.gz

# Extract the zip
tar xzf ~/dotfiles/encrypted.tar.gz -C ~/dotfiles

echo "Loading dotfiles to computer..."

###############################################################################
# GPG
###############################################################################

# Copy .gnupg to home directory
cp -r ~/dotfiles/.gnupg ~/

# Set permissions for .gnupg
chown -R $(whoami) ~/.gnupg/
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg

###############################################################################
# SSH
###############################################################################

# Copy .ssh files to home directory
# This config allows the Apple Keychain to be used for SSH authentication
cp -r ~/dotfiles/.ssh ~/

###############################################################################
# Git
###############################################################################

# Copy .gitconfig to home directory
cp ~/dotfiles/.gitconfig ~/

# Copy .git-credentials to home directory
cp ~/dotfiles/encrypted/.git-credentials ~/

###############################################################################
# Shell
###############################################################################

# Copy .zprofile to home directory
cp ~/dotfiles/.zprofile ~/

# Copy .bashrc to home directory
cp ~/dotfiles/.bashrc ~/

# Copy .zshrc to home directory
cp ~/dotfiles/.zshrc ~/

# Copy .zprofile to home directory
cp ~/dotfiles/.zprofile ~/

###############################################################################
# PyPi
###############################################################################

# Copy .pypirc to home directory
cp ~/dotfiles/encrypted/.pypirc ~/

###############################################################################
# Clean Up
###############################################################################

# Remove dotfiles directory
rm -rf ~/dotfiles

echo "Successfully fetched dotfiles."
