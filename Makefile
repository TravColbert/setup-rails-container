.PONY: help

APP_NAME = thh
APP_VSN ?= `git rev-parse --short HEAD`
CURRENT_IMAGE = $(APP_NAME):$(APP_VSN)
DEV_IMAGE = $(APP_NAME):dev
REPO=$(APP_NAME)
APP_PORT = 3000

help:
	@echo "--------------- $(APP_NAME) ---------------\nImage Tag:\t$(CURRENT_IMAGE)\nDev Image Tag:\t$(DEV_IMAGE)\nDocker Repo:\t$(REPO)\nCommands:"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## builds and tags app image
	docker build \
		-t $(REPO):latest \
		-t $(REPO):dev \
		-t $(REPO):$(APP_VSN) \
		.

install: build ## installs a new rails app
	docker run \
		--mount type=bind,source=$(CURDIR)/app,target=/thh/app \
		--mount type=bind,source=$(CURDIR)/bundle,target=/usr/local/bundle \
		-it \
		--entrypoint "/thh/create_base_app.sh" \
		$(REPO):dev

create: install ## creates a new container
	docker create \
		--mount type=bind,source=$(CURDIR)/app,target=/thh/app \
		--mount type=bind,source=$(CURDIR)/bundle,target=/usr/local/bundle \
		--name $(APP_NAME)_app \
		-p $(APP_PORT):$(APP_PORT) \
		$(REPO):dev

start: create ## starts the base rails app
	docker start $(REPO):dev

up: ## docker-compose up
	docker-compose up

upd: ## docker-compose up
	docker-compose up -d

stop: ## docker-compose stop
	docker-compose stop

down: ## docker-compose down
	docker-compose down

gen_stack: ## generates stack based on layered compose files
	docker-compose \
		-f docker-compose.yml \
		config > docker-stack.yml

test_rails: ## rails test
	docker-compose -f docker-compose.yml -f docker-compose-test.yml run web

push_image: ## push current build image to docker repo
	@echo "Not Implemented"

migrate: ## rails db:migrate
	docker-compose run web bin/rails db:migrate

c: ## rails c
	docker-compose run web bin/rails c
