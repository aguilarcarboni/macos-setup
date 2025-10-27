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

echo "Loading dotfiles to computer..."

###############################################################################
# SSH
###############################################################################

cp -r ~/dotfiles/.ssh ~/

###############################################################################
# Git
###############################################################################

cp ~/dotfiles/.gitconfig ~/

###############################################################################
# Shell
###############################################################################

# Copy .zprofile to home directory
cp ~/dotfiles/.zprofile ~/

# Copy .bashrc to home directory
cp ~/dotfiles/.bashrc ~/

# Copy .zshrc to home directory
cp ~/dotfiles/.zshrc ~/

###############################################################################
# Clean Up
###############################################################################

# Remove dotfiles directory
rm -rf ~/dotfiles

echo "Successfully fetched dotfiles."
