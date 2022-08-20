#!/bin/zsh

# Flags and helpers for better error handling
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# Install brew
# Make sure we can sudo before installing brew
sudo echo 'Starting installation...'
/bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'brew has been installed but needs set your environment to work properly. Either reload your shell or run the command: eval "$(/opt/homebrew/bin/brew shellenv)"'

# We need to have vmware, gnupg, and packer installed
NONINTERACTIVE=1 brew tap hashicorp/tap
NONINTERACTIVE=1 brew install hashicorp/tap/packer
NONINTERACTIVE=1 brew install gnupg

# Install python dependencies
pip3 install -r requirements.txt

# Note: using VMware Fusion first requires adding a license. On macs, this information seems to be stored in the file "/Library/Preferences/VMware Fusion/license-fusion-<some_other_characters>". I'm not sure how to automate this currently so it should be done manually.
echo 'Using VMware Fusion first requires adding a license. On macs, this information seems to be stored in the file "/Library/Preferences/VMware Fusion/license-fusion-<some_other_characters>". I do not know how to automate this currently so it should be done manually.'

# Try to link to the VMware Fusion preview if already installed (the preview is needed for the m1 macs).
if [ -d "/Applications/VMWare Fusion Tech Preview.app" ]; then
    ln -s "/Applications/VMWare Fusion Tech Preview.app" "/Applications/VMWare Fusion.app"
fi

# Initialize packer and its needed plugins
packer init .
