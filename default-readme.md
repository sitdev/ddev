# {{SITE_TITLE}} README

## Getting Started: Local Environment

Clone the repository, and run:

```shell
make
```

This will:

1. Spin up the docker container.
2. Install all dependencies.
3. Run the build process.
4. Initialize local WP<span style="color:red">*</span>.
5. Open a migration dialog to pull staging<span style="color:red">*</span>.

You are now ready to start developing.

## Requirements

- [OrbStack](https://orbstack.dev/)
- [DDEV](https://ddev.readthedocs.io/en/stable/)

For more information on the base DDEV setup, see [https://github.com/sitdev/ddev/](https://github.com/sitdev/ddev/).

## Useful Commands

The Makefile provides several commands to streamline your workflow. Here are the most common ones:

| Command           | Description                                                                                                         |
|-------------------|---------------------------------------------------------------------------------------------------------------------|
| `make help`       | Shows info about most of the available make commands.                                                               |
| `make`            | **Default command.** Runs a one-off build with dev dependencies and exits.                                          |
| `make build`      | Runs a one-off front-end build.                                                                                     |
| `make start`      | Spins up the DDEV container without running a build or server.                                                      |
| `make stop`       | Stops all running DDEV containers.                                                                                  |
| `make install`    | Installs all dev dependencies for Composer and Node.js.                                                             |
| `make update`     | Runs composer update and updates the ddev config.                                                                   |
| `make clean`      | Cleans the build and installed dependencies.                                                                        |
| `make format`     | Automatically formats all source code to match project style guidelines.                                            |
| `make lint`       | Analyzes source code for style issues and potential errors without making changes.                                  |
| `make local-init` | Creates the local-config.php file and initializes the WP database with basic defaults on first run.                 |
| `make xdebug`     | Toggles Xdebug status (off by default).                                                                             |