build:
	podman build -t dynamicledger/activeledger .

build-nocache:
	podman build --no-cache -t dynamicledger/activeledger .

build-testnet: build-nocache
	podman build --no-cache -f Containerfile.testnet -t dynamicledger/activeledger-testnet .

build-verbose:
	podman build --no-cache --progress=plain -t dynamicledger/activeledger .

run-test:
	podman run -it \
	-p 6259:5259 \
	-p 6260:5260 \
	-p 6261:5261 \
	-v ../dl-testnet/dockerication/:/activeledger/data:Z \
	-w /activeledger/data \
	dynamicledger/activeledger

build-test: build-verbose run-test
