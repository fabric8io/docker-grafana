NAME=grafana
VERSION=$(shell cat VERSION)

dev:
	@docker build -f Dockerfile.dev -t $(NAME):dev .
	@docker run --rm \
		-v $(PWD):/go/src/github.com/fabric8io/$(NAME) \
		-e INFLUXDB_SERVICE_NAME=INFLUXDB \
		-e INFLUXDB_SERVICE_HOST=172.30.17.94 \
		-e INFLUXDB_SERVICE_PORT=8086 \
		-e INFLUXDB_PROTO=http \
		-e INFLUXDB_USER=root \
		-e INFLUXDB_PASSWORD=root \
		-p 3000:3000 \
		$(NAME):dev

local: *.go
	go build -ldflags "-X main.Version $(VERSION)-dev" -o build/$(NAME)

build:
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create fabric8io/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

.PHONY: dev build release
