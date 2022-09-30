# Situation DDEV
# Version: 0.0.1

UPDATE_BRANCH="main"
.PHONY: *

all: develop help

develop: start install build container-sync ## Turn on ddev and run build
production: start install-production build-production container-sync ## Run the production build

install: ## Install all dev dependencies
	@ddev composer install --prefer-source
	@ddev yarn-install
	@make container-sync

install-production: ## Install all production dependencies
	@ddev composer install -o --no-dev
	@ddev yarn-install
	@make container-sync

build: ## Run front-end dev build
	@ddev yarn-build

build-production: ## Run front-end production build
	@ddev yarn-build production

start: ## Turn on ddev
	@docker stats --no-stream &> /dev/null || colima start
	@[ -d .ddev ] || make self-update
	@if [ ! -z "$$(make running 2>/dev/null)" ]; then \
		if ddev list | grep -q running; then \
		  ddev poweroff; \
		fi; \
		ddev start && ddev auth ssh && make container-sync; \
	fi

stop: ## Shut down ddev
	-@ddev poweroff

restart: stop start ## Restart ddev

shutdown: stop clean ## Clean build, full shutdown of ddev/colima
	-@colima stop

container-sync:
	@ddev mutagen sync

watch: ## Start the watch task
	@ddev yarn-watch
	
logging: ## Tail the ddev log
	@ddev logs -f

clean: ## Clean build
	@rm -rf wp-content/vendor wp-content/plugins wp wp-content/themes/orchestrator
	@find . -type d -name "node_modules" -prune -exec rm -rf {} \;
	@find wp-content/themes -type d -name "bower_components" -prune -exec rm -rf {} \;
	@find wp-content/themes -type d  -name "dist" -prune -exec rm -rf {} \;

reset-project: clean ## Clean build and git hard reset/pull
	@mv wp-content/uploads ./ && rm -rf wp-content && mkdir -p wp-content && mv uploads wp-content/
	@git add -A .
	@git reset --hard
	@git fetch
	@git pull

update: running ## Composer update
	@ddev composer update -o --no-install
	@make self-update
	@make restart

remove-project: ## Remove project from DDEV project list
	-@ddev delete -O

reset-ddev: ## Remove all projects from DDEV project list, remove ddev docker images from cache
	-@ddev delete --all -O
	-@ddev clean --all

reset-docker: ## Remove all docker images from system
	-@docker rmi -f $(docker images -q)
	-@docker system prune -af && docker volume prune

factory-reset: clean reset-ddev reset-docker ## Full project clean and reset of ddev and docker

self-update: ## Update Situation ddev config from remote repository
	@[ -z ${UPDATE_BRANCH} ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/sitdev/ddev/main/install.sh)" -- "${UPDATE_BRANCH}" 

local-init: ## Initialize local WP database using basic defaults
	@ddev local-config
	@ddev local-init

pull-staging: ## Run a pre-defined WP Migrate DB profile to pull the staging environment
	@ddev run-migration pull-staging

pull-production: ## Run a pre-defined WP Migrate DB profile to pull the production environment
	@ddev run-migration pull-production

status: ## Show project status and tools
	@ddev status

mailhog: ## Launch mailhog in browser
	@ddev launch -m

sequelpro: ## Open current project database in Sequel Pro
	@ddev sequelpro

xdebug: ## Start Xdebug
	@ddev xdebug on

running:
	@[ ! -z "$$(ddev exec pwd 2>/dev/null)" ] || (echo "Run \"make\" or \"make start\" to start"; exit 1)

help: ## Show this dialog
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@printf "\nAdditional commands:\n\n  ddev composer *\n  ddev yarn *\n\nMore: https://ddev.readthedocs.io/en/latest/users/basics/cli-usage/\n\n"
