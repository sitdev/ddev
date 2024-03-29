#!/usr/bin/env bash

# Call the function and assign the result to a variable
os=$(get_os)
if [[ $os == "macOS" ]]; then
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
    printf "\nPlease install Homebrew following instructions here: https://brew.sh/\n\n"
    exit 1
  fi
fi

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  printf "\nPlease install Docker: \n  brew install docker\n\n"
  exit 1
fi

# Check if DDEV is installed
if ! command -v ddev >/dev/null 2>&1; then
  printf "\nPlease install DDEV:\n\
==========\n\
  brew install drud/ddev/ddev\\n\
  brew install nss\n\
  mkcert -install\n\
  ddev config global --mutagen-enabled\n\
==========\n\n"
  exit 1
fi
