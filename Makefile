build:
	./create_sh_layer.sh

load: build
	tar cvf - \
	  layer-1.json layer-1.tar \
	  manifest.json \
	| docker load

run: load
	-docker run --rm bencord0/sh

.PHONY: build load run
