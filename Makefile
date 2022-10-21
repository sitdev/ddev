# Situation DDEV
# Version: 0.0.1

UPDATE_BRANCH="main"
.PHONY: *

all: develop
	@ddev wp core is-installed &> /dev/null || make local-init
	@printf "\nEnter \033[36mmake help\033[0m for more info\n\n"

develop: start install build container-sync ## Turn on ddev and run build (default)
production: start install-production build-production container-sync ## Create the production build

install: ## Install all dev dependencies
	@ddev composer install -o --prefer-source
	@ddev yarn-install

install-production:
	@ddev composer install -o --no-dev
	@ddev yarn-install

build: ## Run front-end dev build
	@ddev yarn-build

build-production:
	@ddev yarn-build production

start: ## Turn on ddev
	@docker stats --no-stream &> /dev/null || colima start
	@[ -d .ddev ] || make self-update
	@if [ ! -z "$$(make running 2>/dev/null)" ]; then \
		if ddev list | grep -q running; then \
		  ddev poweroff; \
		fi; \
		ddev start && ddev auth ssh && make status; \
	fi
	

stop: ## Shut down ddev
	-@ddev poweroff

restart: stop start ## Restart ddev

shutdown: stop ## Clean build, full shutdown of ddev/colima
	-@colima stop

container-sync:
	@echo "Syncing mutagen container..."
	@ddev mutagen sync 2> /dev/null || ddev mutagen reset || true

watch: ## Start the watch task
	@ddev yarn-watch
	
logging: ## Tail the ddev log
	@ddev logs -f --tail 10

clean: ## Clean build
	@isRunning="$$(ddev exec pwd 2>/dev/null)"; \
	/bin/bash .ddev/commands/host/clean-build; \
	ddev mutagen reset || true; \
	[ ! -z "$${isRunning}" ] && make start || true

reset: self-update ## Clean build and git hard reset/pull
	@/bin/bash .ddev/commands/host/hard-reset

update: start ## Composer update
	@ddev platform-update
	@[ ! -z "$$(make self-update)" ] && make restart || true

self-update: ## Update Situation ddev config from remote repository. Branch is defined by $UPDATE_BRANCH.
	@[ -z ${UPDATE_BRANCH} ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)" -- "${UPDATE_BRANCH}" 

local-init: start ## Initialize local WP database using basic defaults
	@ddev composer install -o --prefer-source
	@ddev local-config
	@make container-sync
	@ddev local-init
	@ddev migration

migration: ## Start Migration dialog to create new or run existing migrations
	@ddev migration

pull-staging: ## Run a pre-defined WP Migrate DB profile to pull the staging environment
	@ddev run-migration pull-staging

pull-production: ## Run a pre-defined WP Migrate DB profile to pull the production environment
	@ddev run-migration pull-production

plugin-dev-mode: ## Toggles an alternate build process which clears and re-installs all Situation node_modules content before each build.
	@ddev toggle-plugin-dev-mode

status: ## Show project status and tools
	@ddev status

mailhog: ## Launch mailhog in browser
	@ddev launch -m

sequelpro: ## Open current project database in Sequel Pro
	@ddev sequelpro || ddev sequelace 

xdebug: ## Toggle Xdebug (off by default)
	@ddev toggle-xdebug

running:
	@[ ! -z "$$(ddev exec pwd 2>/dev/null)" ] || (echo "Run \"make\" or \"make start\" to start"; exit 1)

remove-project: ## Remove project from DDEV project list. Local db is deleted, files are not
	-@ddev delete -O

reset-ddev: # Remove all projects from DDEV project list, remove ddev docker images from cache
	-@ddev delete --all -O
	-@ddev clean --all

reset-docker: # Remove all docker images from system
	-@docker rmi -f $(docker images -q)
	-@docker system prune -af && docker volume prune

factory-reset: reset-ddev reset-docker # Full project clean and global reset of ddev and docker. Mainly useful for testing or freeing up disk space.

help: ## Show this dialog
	@printf "\nMakefile help documentation:\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@printf "\nAdditional commands:\n\n  ddev composer *\n  ddev yarn *\n\nMore: https://ddev.readthedocs.io/en/latest/users/basics/cli-usage/\n\n"
