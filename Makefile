.DEFAULT_GOAL := run
.PHONY: all build run clean vacuum

all: clean run

build:
	@ docker-compose up --no-start

run: build
	@ ./gcloud.rb

clean:
	@ docker-compose down
	@ docker-compose down --volumes
	@ docker-compose down --rmi local
	@ rm -f config.yml

vacuum: clean
	@ (docker images | grep cloud-sdk && docker-compose down --rmi all) || true
