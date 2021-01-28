.DEFAULT_GOAL := run
.PHONY: all build run clean

all: clean build run

build:
	@ docker-compose up --no-start

run: build
	@ ./gcloud.rb

clean:
	@ docker-compose down
	@ docker-compose down --volumes
	@ docker-compose down --rmi local
	@ (docker image ls | grep cloud-sdk) && docker-compose down --rmi all || true
	@ rm -f config.yml
