# Situation DDEV
# Version: 0.0.1

UPDATE_BRANCH="main"
.PHONY: *

all: develop
	@ddev wp core is-installed >/dev/null 2>&1 || make local-init
	@printf "\nEnter \033[36mmake help\033[0m for more info\n\n"

develop: start install build container-sync ## Turn on ddev and run build (default)
production: start install-production build-production container-sync ## Create the production build

install: ## Install all dev dependencies
	@ddev composer-install
	@ddev yarn-install

install-production:
	@ddev composer install -o --no-dev
	@ddev yarn-install

build: ## Run front-end dev build
	@ddev yarn-build

build-production:
	@ddev yarn-build production

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
	@ddev validate-architecture
	
stop: ## Shut down ddev
	-@ddev poweroff

restart: stop start ## Restart ddev

container-sync:
	@echo "Syncing mutagen container..."
	@make running 2>/dev/null && ddev mutagen sync || ddev mutagen reset

watch: ## Start the watch task
	@ddev yarn-watch
	
lint: ## Lint source files
	@ddev yarn-lint

format: ## Format source files
	@ddev yarn-lint

logging: ## Tail the ddev log
	@ddev log-tail

clean: ## Clean build
	@ddev clean-build

reset: ## Clean build and git hard reset/pull
	-@ddev stop
	@make self-update
	@ddev hard-reset

update: clean start ## Composer update
	@ddev platform-update
	@make

update-review: ## Full reset and update process with manual comparison against a remote install for code changes and visual regression.
	@ddev update-review

self-update: ## Update Situation ddev config from remote repository. Branch is defined by $UPDATE_BRANCH.
	@[ -z ${UPDATE_BRANCH} ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)" -- "${UPDATE_BRANCH}" 

node20-upgrade:
	@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/bin/node20-upgrade.sh)"

local-init: start ## Initialize local WP database using basic defaults
	@ddev composer-install
	@ddev local-config
	@make container-sync
	@ddev local-init
	@ddev migration

migration: ## Start Migration dialog to create new or run existing migrations
	@ddev migration

pull-staging: ## Run a pre-defined WP Migrate DB profile to pull the staging environment
	@ddev pull-media develop
	@ddev run-migration pull-staging

pull-production: ## Run a pre-defined WP Migrate DB profile to pull the production environment
	@ddev pull-media master
	@ddev run-migration pull-production

test: 
	@ddev test-phpunit

plugin-dev-mode: ## Toggles an alternate build process which clears and re-installs all Situation node_modules content before each build.
	@/bin/bash .ddev/commands/host/toggle-plugin-dev-mode

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
