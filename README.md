A DDEV setup for Situation Group developers and freelancers.

## Getting Started

For Windows, see [Setting up DDEV on Windows](https://www.google.com/search?q=docs/windows-setup.md)

## Requirements (macOS)

### OrbStack

We recommend using OrbStack as your Docker provider. It is a fast, lightweight, and easy-to-use replacement for Docker
Desktop.

1. **Install OrbStack:**
   ```shell
   brew install orbstack
   ```
2. **Run OrbStack:** Launch the OrbStack application. Once it's running, DDEV will use it automatically.

That's it. OrbStack handles file mounts and system resources seamlessly, so you typically do not need to configure CPU,
memory, or disk settings via the command line.

### DDEV

```shell
brew install ddev/ddev/ddev
mkcert -install
ddev config global --performance-mode mutagen
```

### First Run

If your project does not have a Makefile yet, run the following inside your project repository/webroot:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)"
```

## More Documentation

[https://ddev.readthedocs.io/en/stable/](https://ddev.readthedocs.io/en/stable/)

## Useful Commands

| Command                | Description                                                                                                                      |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `make help`            | Shows info about most of the available make commands.                                                                            |
| `make`                 | **Default command.** Runs a one-off build with dev dependencies and exits.                                                       |
| `make dev`             | **Primary dev command.** Starts a full "cold start" session: turns on DDEV, installs dependencies, and runs the Vite dev server. |
| `make build`           | Runs a one-off front-end build.                                                                                                  |
| `make start`           | Spins up the DDEV container without running a build or server.                                                                   |
| `make stop`            | Stops all running DDEV containers.                                                                                               |
| `make install`         | Installs all dev dependencies for Composer and Node.js.                                                                          |
| `make update`          | Runs composer update and updates the Makefile and DDEV configuration files from this repo.                                       |
| `make clean`           | Cleans the build and installed dependencies.                                                                                     |
| `make format`          | Automatically formats all source code to match project style guidelines.                                                         |
| `make lint`            | Analyzes source code for style issues and potential errors without making changes.                                               |
| `make local-init`      | Initializes the local WP database with basic defaults using wp-cli.                                                              |
| `make xdebug`          | Toggles Xdebug status (off by default).                                                                                          |
| `make plugin-dev-mode` | Toggles an alternate build process which clears and re-installs all Situation node\_modules content before each build.           |
