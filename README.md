A DDEV setup for The Studio at Situation Group developers and freelancers.

## Getting Started

Inside your project repository/webroot, run the following:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)"
```

## Requirements

### Colima
```shell
brew install colima
colima start --cpu 4 --memory 6 --disk 100
```

Note: if your web project parent directory is not somewhere in your `$HOME` folder, replace the colima start command above with this:
```shell
colima start --cpu 4 --memory 6 --disk 100 --mount "/Volumes/my-project-parent:w" --mount "~:w"
```

### DDEV
```shell
brew install drud/ddev/ddev
brew install nss
mkcert -install
ddev config global --mutagen-enabled
```

## More Documentation
https://ddev.readthedocs.io/en/stable/

## Useful Commands

| Command                | Description                                                                                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `make help `           | Shows info about most of the available make commands.                                                                                                                  |
| `make`                 | Spins up the ddev container, runs the full build, and starts a migration dialog on first run.                                                                          |
| `make start`           | Spins up the ddev container.                                                                                                                                           |
| `make stop`            | Stops all running ddev containers.                                                                                                                                     |
| `make install`         | Installs all of the dev dependencies for composer and yarn.                                                                                                            |
| `make build`           | Runs the development build.                                                                                                                                            |
| `make watch`           | Runs the watch task.                                                                                                                                                   |
| `make update`          | Runs composer update and updates the Makefile and ddev configuration files from this repo.                                                                             |
| `make clean`           | Cleans the build and installed dependencies.                                                                                                                           |
| `make local-init`      | Creates the local-config.php file and initializes the WP database with basic defaults using wp-cli.                                                                    |
| `make xdebug`          | Toggles Xdebug status (off by default). Works out of the box with phpstorm, but you will need to clear any previous xdebug mappings under Preferences > PHP > Servers. |
| `make plugin-dev-mode` | Toggles an alternate build process which clears and re-installs all Situation node_modules content before each build.                                                  |

