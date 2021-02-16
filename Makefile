.DEFAULT_GOAL := run
.PHONY: all build run shell clean vacuum

all: clean run

build:
	@ docker-compose build

config.yml:
	@ [ -f config.yml ] || touch config.yml

run: config.yml
	@ docker-compose run --rm app

shell: config.yml
	@ docker-compose run --rm --entrypoint=/bin/bash app

clean:
	@ docker-compose down
	@ docker-compose down --volumes
	@ docker-compose down --rmi local
	@ rm -f config.yml

vacuum: clean
	@ (docker images | grep gcr.io/google.com/cloudsdktool/cloud-sdk 1> /dev/null && docker-compose down --rmi all) || true
