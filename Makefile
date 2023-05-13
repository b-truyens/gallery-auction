.PHONY: help ps fresh build start stop destroy tests tests-html migrate \
	migrate-fresh migrate-tests-fresh install-xdebug create-env

sail := vendor/bin/sail

PROJECT_NAME=gallery-auction

CONTAINER_PHP=gallery-auction-laravel.test-1
CONTAINER_DB=gallery-auction-mysql-1
CONTAINER_NODE=gallery-auction-laravel.test-1

VOLUME_DATABASE=gallery-auction_sail-mysql
VOLUME_DATABASE_TESTING=db-testing-data

help: ## Print help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ps: ## Show containers.
	@$(sail) ps

fresh: stop destroy build ## Destroy & recreate all containers.

build: ## Build all containers.
	@$(sail) build --no-cache

start: ## Start all containers.
	@$(sail) up --force-recreate -d

stop: ## Stop all containers.
	@$(sail) stop

destroy: ## Destroy all containers & purge volumes.
	@$(sail) down -v

tests: ## Run all tests.
	docker exec ${CONTAINER_PHP} ./vendor/bin/phpunit

tests-html: ## Run tests + generate coverage.
	docker exec ${CONTAINER_PHP} php -d zend_extension=xdebug.so -d xdebug.mode=coverage ./vendor/bin/phpunit --coverage-html reports

migrate: ## Run migration files.
	@$(sail) artisan migrate

migrate-fresh: ## Clear database and run all migrations.
	@$(sail) artisan migrate:fresh

#migrate-tests-fresh: ## Clear database and run all migrations.
#	docker exec ${CONTAINER_PHP} php artisan --env=testing migrate:fresh

install-xdebug: ## Install xdebug locally.
	docker exec ${CONTAINER_PHP} pecl install xdebug
	docker exec ${CONTAINER_PHP} /usr/local/bin/docker-php-ext-enable xdebug.so

create-env: ## Copy .env.example to .env
	@if [ ! -f ".env" ]; then \
		echo "Creating .env file."; \
		cp .env.example .env; \
	fi

ssh-php:
	docker exec -it ${CONTAINER_PHP} sh

ssh-db:
	docker exec -it ${CONTAINER_DB} sh

ssh-node:
	docker exec -it ${CONTAINER_NODE} sh

node-install: 
	@$(sail) npm install 
node-run:
	@$(sail) npm run build