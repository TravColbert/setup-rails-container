.PONY: help

APP_NAME?=my_app
CURRENT_IMAGE=$(APP_NAME):$(APP_VSN)
DEV_IMAGE=$(APP_NAME):dev
APP_VSN?=`git rev-parse --short HEAD`
APP_PORT?=3000

help:
	@echo "--------------- $(APP_NAME) ---------------\nImage Tag:\t$(CURRENT_IMAGE)\nDev Image Tag:\t$(DEV_IMAGE)\nDocker Repo:\t$(REPO)\nCommands:"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## builds and tags app image
	docker build \
		-t $(APP_NAME):latest \
		-t $(APP_NAME):dev \
		-t $(APP_NAME):$(APP_VSN) \
		--build-arg app_name=$(APP_NAME) \
		.

install: build ## installs a new rails app
	docker run \
		--mount type=bind,source=$(CURDIR)/app,target=/$(APP_NAME)/app \
		--mount type=bind,source=$(CURDIR)/bundle,target=/usr/local/bundle \
		-it \
		--entrypoint "/$(APP_NAME)/create_base_app.sh" \
		$(APP_NAME):dev

create: install ## creates a new container
	docker create \
		--mount type=bind,source=$(CURDIR)/app,target=/$(APP_NAME)/app \
		--mount type=bind,source=$(CURDIR)/bundle,target=/usr/local/bundle \
		--name $(APP_NAME)_app \
		-p $(APP_PORT):$(APP_PORT) \
		$(APP_NAME):dev

start: ## starts the base rails app
	docker start -ai $(APP_NAME)_app

shell: ## container to bash
	docker exec -it $(APP_NAME)_app bash

console: ## container to bash
	docker exec -it $(APP_NAME)_app rails c

attach: ## connect to running rails container console
	docker attach $(APP_NAME)_app
