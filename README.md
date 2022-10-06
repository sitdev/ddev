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

## More Documentation
https://ddev.readthedocs.io/en/stable/

## Useful Commands

| Command        | Info                                                                                       |
|----------------|--------------------------------------------------------------------------------------------|
| `make help `   | Shows info about most of the available make commands.                                      |
| `make`         | Spins up the ddev container, runs the full build.                                          |
| `make start`   | Spins up the ddev container.                                                               |
| `make stop`    | Stops all running ddev containers.                                                         |
| `make install` | Installs all of the composer and yarn dev dependencies.                                    |
| `make build`   | Runs the development build.                                                                |
| `make watch`   | Runs the watch task.                                                                       |
| `make update`  | Runs composer update and updates the Makefile and ddev configuration files from this repo. |
| `make clean`   | Cleans the build and installed dependencies.                                               |
