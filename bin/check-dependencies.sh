#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
  printf "\nPlease install Homebrew following instructions here: https://brew.sh/\n\n"
  exit 1
fi

# Check if Docker is installed
if ! command -v docker &>/dev/null; then
  printf "\nPlease install Docker: \n  brew install docker\n\n"
  exit 1
fi

# Check if Colima is installed
if ! command -v colima &>/dev/null; then
  printf "\nPlease install Colima: https://ddev.readthedocs.io/en/stable/users/install/docker-installation/\n\
==========\n\
  brew install colima\n\
  colima start --cpu 4 --memory 6 --disk 100 \n\
==========\n\
Note: if your web project parent directory is not somewhere in your $HOME folder, \n\
replace the colima start command above with this:\n\
  colima start --cpu 4 --memory 6 --disk 100 --mount \"/Volumes/my-project-parent:w\" --mount \"~:w\"\n\n"
  exit 1
fi

# Check if DDEV is installed
if ! command -v ddev &>/dev/null; then
  printf "\nPlease install DDEV:\n\
==========\n\
  brew install drud/ddev/ddev\\n\
  brew install nss\n\
  mkcert -install\n\
  ddev config global --mutagen-enabled\n\
==========\n\n"
  exit 1
fi
