build/container: stage/grafana Dockerfile
	docker build --no-cache -t grafana .
	touch build/container

build/grafana: *.go
	GOOS=linux GOARCH=amd64 go build -o build/grafana
	GOOS=linux GOARCH=amd64 go test

stage/grafana: build/grafana
	mkdir -p stage
	cp build/grafana stage/grafana

release:
	docker tag grafana jimmidyson/grafana
	docker push jimmidyson/grafana

.PHONY: clean
clean:
	rm -rf build
