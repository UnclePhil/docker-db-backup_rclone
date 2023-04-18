# import secret deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
# don't forget to put this file in .gitignore 
dck ?= ~/.pko_config/.docker/.docker
dckpw ?= ~/.pko_config/.docker/.dockerpw
include $(dck)
export $(shell sed 's/=.*//' $(dck))

# import deploy config
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# get the version from the date/time
# VERSION=$(shell date '+%Y%m%d%H%M%S')
DT=$(shell date '+%Y%m%d%H%M')
## RVERSION=$(VERSION)-${DT}
RVERSION=$(VERSION)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build --rm --force-rm --build-arg VERSION=$(RVERSION) --build-arg SRC_IMG=$(SRC_IMG) -t $(APP_NAME):$(RVERSION) .

build-nc: ## Build the container without caching
	docker build --no-cache --rm --force-rm --build-arg VERSION=$(RVERSION) --build-arg SRC_IMG=$(SRC_IMG) -t $(APP_NAME):$(RVERSION) .

# Run the container 
run: ## Run container on port configured in `deploy.env`
	docker run -i -t --rm -p=$(APP_PORT):$(APP_PORT) --name="$(APP_NAME)" $(APP_NAME):$(RVERSION)


up: build run ## Run container on port configured in `deploy.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

dev: build-nc repo-login publish-dev 

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish: repo-login publish-version publish-latest ## Publish the `{version}` ans `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DREPO)'
	docker push $(DREPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'publish $(VERSION) to $(DREPO)'
	docker push $(DREPO)/$(APP_NAME):$(VERSION)

publish-dev: tag-dev ## Publish the `{version}` taged container to ECR
	@echo 'publish $(RVERSION) to $(DREPO)'
	docker push $(DREPO)/$(APP_NAME):develop


# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME):${RVERSION} $(DREPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME):${RVERSION} $(DREPO)/$(APP_NAME):$(VERSION)

tag-dev: ## Generate container `latest` tag
	@echo 'create tag develop'
	docker tag $(APP_NAME):${RVERSION} $(DREPO)/$(APP_NAME):develop


# login to docker hub
repo-login: 
	cat $(dckpw)| docker login -u $(DUSER) --password-stdin

version: ## Output the current version
	@echo $(RVERSION)
	
