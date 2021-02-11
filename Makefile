.DEFAULT_GOAL := run
.PHONY: all build run clean vacuum

all: clean run

build:
	@ docker-compose build

run:
	@ [ -f config.yml ] || touch config.yml
	@ docker-compose run --rm app

clean:
	@ docker-compose down
	@ docker-compose down --volumes
	@ docker-compose down --rmi local
	@ rm -f config.yml

vacuum: clean
	@ (docker images | grep gcr.io/google.com/cloudsdktool/cloud-sdk 1> /dev/null && docker-compose down --rmi all) || true
