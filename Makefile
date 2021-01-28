.DEFAULT_GOAL := run
.PHONY: all build run clean

all: clean build run

build:
	@ docker-compose up --no-start

run: build
	@ ./gcloud.rb

clean:
	@docker-compose down
	@rm -f config.yml
	@docker volume rm turbulence_gcloud_auth
	@docker volume rm turbulence_kube_config
