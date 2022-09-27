# Situation DDEV
# Version: 0.0.1
# System setup:
#	brew install colima
#	colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1
#	# If your main projects folder isn't in your $HOME directory, use this
#		(replace "/Volumes/dev" with your project parent location):
#		colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1 --mount "/Volumes/dev:w" --mount "~:w"
#	brew install drud/ddev/ddev
#	brew install nss
#	mkcert -install
#	ddev config global --mutagen-enabled

UPDATE_BRANCH="main"
.PHONY: *

init: start develop

testing:
	@[ -d .ddev ] || echo 'not exists'

start:
	@docker stats --no-stream &> /dev/null || colima start
	@ddev list | grep -v "$$(pwd)" | grep "running" &> /dev/null && ddev poweroff || continue 
	@ddev list | grep "$$(pwd)" | grep "running" &> /dev/null || (ddev start && ddev auth ssh && make mutagen-sync)

stop:
	-@ddev poweroff

restart: stop start

shutdown: stop clean
	-@colima stop

develop: running composer-develop yarn-develop mutagen-sync

production: running composer-production yarn-production mutagen-sync

composer-develop:
	@ddev composer install -o --prefer-source

composer-production:
	@ddev composer install -o --no-dev

yarn-develop:
	@ddev yarn platform-reset
	@ddev yarn develop

yarn-production:
	@ddev yarn
	@ddev yarn production

mutagen-sync:
	@ddev mutagen sync

watch:
	@ddev yarn watch
	
logging:
	@ddev logs -f

clean:
	@rm -rf wp-content/vendor wp-content/plugins wp wp-content/themes/orchestrator
	@find . -type d -name "node_modules" -prune -exec rm -rf {} \;
	@find wp-content/themes -type d -name "bower_components" -prune -exec rm -rf {} \;
	@find wp-content/themes -type d  -name "dist" -prune -exec rm -rf {} \;
	@ddev mutagen sync &> /dev/null || continue

reset-project: clean
	@git add -A .
	@git reset --hard
	@git fetch
	@git pull

update: running
	@ddev composer update -o --no-install

remove-project:
	-@ddev delete -O

reset-ddev:
	-@ddev delete --all -O
	-@ddev clean --all

reset-docker:
	-@docker rmi -f $(docker images -q)
	-@docker system prune -af && docker volume prune

factory-reset: clean reset-ddev reset-docker

self-update:
	@curl -s https://raw.githubusercontent.com/sitdev/ddev/main/install.sh | bash /dev/stdin ${UPDATE_BRANCH}

status:
	@ddev status

mailhog:
	@ddev launch -m

sequelpro:
	@ddev sequelpro

pull-staging:
	@ddev run-migration pull-staging

pull-production:
	@ddev run-migration pull-production

xdebug:
	@ddev xdebug on

running:
	@ddev list | grep "$$(pwd)" | grep "running" &> /dev/null || (echo "Run Make to start" && exit 1)
