# Situation DDEV
# Version: 0.0.1

UPDATE_BRANCH="static"
.PHONY: *

all: develop

develop: start
production: start

install: 

install-production:

build:

build-production:

start: ## Turn on ddev
	@if ! docker info >/dev/null 2>&1; then \
		if command -v colima >/dev/null 2>&1; then \
		  colima start; \
		else \
			echo "Docker doesn't appear to be running"; \
			exit 1; \
		fi; \
  	fi
  		 
	@if ! make running 2>/dev/null; then \
		if ddev list | grep -qi ok; then \
		  ddev poweroff; \
		fi; \
		make self-update; \
		ddev start && ddev auth ssh && ddev composer-auth && make status; \
	fi
	
stop: ## Shut down ddev
	-@ddev poweroff

restart: stop start ## Restart ddev

shutdown: stop ## Clean build, full shutdown of ddev/colima
	-@colima stop

container-sync:
	@echo "Syncing mutagen container..."
	@make running 2>/dev/null && ddev mutagen sync || ddev mutagen reset

watch:
	
logging: ## Tail the ddev log
	@ddev log-tail

clean:

reset: self-update

update: start

update-review: 

self-update: ## Update Situation ddev config from remote repository. Branch is defined by $UPDATE_BRANCH.
	@[ -z ${UPDATE_BRANCH} ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)" -- "${UPDATE_BRANCH}" 

local-init: start

migration:

pull-staging:

pull-production:

test: 
	@ddev test-phpunit

plugin-dev-mode:

status: ## Show project status and tools
	@ddev status

mailhog: ## Launch mailhog in browser
	@ddev launch -m

sequelpro: ## Open current project database in Sequel Pro
	@ddev sequelpro || ddev sequelace 

xdebug: ## Toggle Xdebug (off by default)
	@ddev toggle-xdebug

running:
	@ddev exec pwd >/dev/null 2>&1 || exit 1

remove-project: ## Remove project from DDEV project list. Local db is deleted, files are not
	-@ddev delete -O

system-reset-ddev: # Remove all projects from DDEV project list, remove ddev docker images from cache
	-@ddev delete --all -O
	-@ddev clean --all

system-reset-docker: # Remove all docker images from system
	-@docker system prune -a --volumes

system-factory-reset: system-reset-ddev system-reset-docker # Full project clean and global reset of ddev and docker. Mainly useful for testing or freeing up disk space.

help: ## Show this dialog
	@printf "\nMakefile help documentation:\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@printf "\nAdditional commands:\n\n  ddev composer *\n  ddev yarn *\n\nMore: https://ddev.readthedocs.io/en/latest/users/basics/cli-usage/\n\n"
