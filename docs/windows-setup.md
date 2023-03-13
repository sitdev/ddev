# Windows DDEV using WSL2

This document provides instructions on how to set up DDEV using WSL2 on Windows. After following the instructions, the DDEV and WSL2 installation will use approximately 11GB of disk space. The guide includes step-by-step instructions for installing WSL2 with Ubuntu, setting up SSH configuration, installing dependencies, setting up a project, and integrating with VS Code.

## **Install WSL2 with Ubuntu**

Run the following in an administrative PowerShell terminal:

```bash
wsl --install
```

Reboot and wait for Ubuntu to finish installing.

### DDEV Install

Run the following in an administrative PowerShell:

```bash
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ddev/ddev/master/scripts/install_ddev_wsl2_docker_inside.ps1'))
```

More detailed instructions can be found on the DDEV “[Getting Started](https://ddev.com/get-started/)” page.

### SSH Config

If you haven't added an [SSH key to your GitHub account](https://github.com/settings/keys), follow the [instructions provided by GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to do so. You may wish to leave the passphrase blank, as it will be requested frequently during the normal composer install process.

To copy the .ssh folder from the Windows installation into the WSL container user directory and update the correct permissions:

1. Open the WSL2 terminal (Start > Ubuntu)
2. Copy the .ssh folder to the WSL2 instance by using the `cp` command:
   Replace `<windows-username>` with your actual Windows username.

    ```bash
    cp -r /mnt/c/Users/<windows-username>/.ssh ~/
    ```

3. Update the correct permissions for the .ssh folder and files inside:

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
    chmod 644 ~/.ssh/*.pub
    ```

   ### WSL Dependencies

   In the WSL2 instance terminal, install `make`:

    ```bash
    sudo apt-get install make
    ```

   ### Project Setup

   In the WSL2 instance terminal, set up your first project.

    ```bash
    mkdir ~/projects
    cd ~/projects
    git clone git@github.com:situationinteractive/{project}.git
    cd {project}
    git checkout develop
    make
    ```

   On first run, you may run into an error during `make`. If so, just run `make` again and it should be resolved. If not, a system reboot may be required.

   ### VS Code integration

   If you don't already have it, you can install VS Code from an administrative Powershell terminal:

    ```bash
    choco install vscode
    ```

   To connect to a codebase in a WSL2 instance using VS Code, you will first need to install the [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension in VS Code.

   Once the extension is installed, you can open your project in VS Code by running the command `code .` in the WSL2 terminal. This will launch a new instance of VS Code with the codebase open and ready to work on. Any VS Code terminal opened within the project is a WSL2 terminal, so all `make` commands can be conveniently run from that environment, and a separate WSL2 terminal is no longer necessary.