#!/bin/bash

which brew &> /dev/null || printf "\nPlease install Homebrew following instructions here: https://brew.sh/\n\n"

if [ ! $(which docker) ] ; then 
  printf "\nPlease install docker: \n  brew install docker\n\n"
  exit
fi

if [ ! $(which colima) ] ; then 
  printf "\nPlease install colima: https://ddev.readthedocs.io/en/stable/users/install/docker-installation/\n\
==========\n\
  brew install colima\n\
  colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1\n\
==========\n\
Note: if your web project parent directory is not somewhere in your $HOME folder, \n\
replace the colima start command above with this:\n\
  colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1 --mount \"/Volumes/my-project-parent:w\" --mount \"~:w\"\n\n"
fi
if [ ! $(which ddev) ]; then 
  printf "\nPlease install ddev:\n\
==========\n\
  brew install drud/ddev/ddev\\n\
  brew install nss\n\
  mkcert -install\n\
  ddev config global --mutagen-enabled\n\
==========\n\n" 
  exit
fi