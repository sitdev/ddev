A DDEV setup for The Studio at Situation Group developers and freelancers.

## Getting Started:

Inside your project repository/webroot, run the following:

$ `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)"`

## Requirements

### Colima
```
brew install colima
colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1
```

Note: if your web project parent directory is not somewhere in your `$HOME` folder, replace the colima start command above with this:
```
colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1 --mount "/Volumes/my-project-parent:w" --mount "~:w"
```

### DDEV
```
brew install drud/ddev/ddev
brew install nss
mkcert -install
ddev config global --mutagen-enabled
```
