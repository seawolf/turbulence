.DEFAULT_GOAL := run
.PHONY: all build build_fresh run shell clean vacuum

all: clean run

build: config.yml
	@ docker compose build

build_fresh: config.yml
	@ docker compose build --no-cache

config.yml:
	@ [ -f config.yml ] || touch config.yml

run: config.yml
	@ docker compose run --rm --service-ports app

shell: config.yml
	@ docker compose run --rm --service-ports --entrypoint=/bin/bash app

clean:
	@ docker compose down
	@ docker compose down --volumes
	@ docker compose down --rmi local
	@ rm -f config.yml

vacuum: clean
	@ (docker images | grep gcr.io/google.com/cloudsdktool/cloud-sdk 1> /dev/null && docker compose down --rmi all) || true
