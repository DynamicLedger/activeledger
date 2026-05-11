# Stage 1 - builder
FROM node:20-bookworm AS builder

WORKDIR /activeledger

RUN apt-get update && apt-get install -y \
    python3 \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g lerna

COPY package*.json ./
RUN npm install

COPY . .
RUN find . -path "*/rocksdb/build/Release/leveldown.node" -delete && \
    npm rebuild leveldown --build-from-source && \
    npm run build

# Stage 2 - runtime
FROM node:20-bookworm-slim AS runtime

WORKDIR /activeledger

# Required for rocksdb
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /activeledger/packages ./packages

# Remove unneeded files to reduce size
RUN find ./packages -type d -name "src" -exec rm -rf {} + ; true \
    && find ./packages -type d -name "test" -exec rm -rf {} + ; true \
    && find ./packages -type d -name "tests" -exec rm -rf {} + ; true

# Setup run files
COPY build/activeledger.sh /usr/local/bin/activeledger
COPY build/restore.sh /usr/local/bin/activerestore
COPY build/core.sh /usr/local/bin/activecore
RUN chmod +x /usr/local/bin/activeledger \
    && chmod +x /usr/local/bin/activerestore \
    && chmod +x /usr/local/bin/activecore

# Not used in this container, used by the testnet expansion containerfile
# These are separate on purpose, this container should not be used to make testnet
# using that script
COPY build/testnet-entrypoint.sh /usr/local/bin/testnet-entrypoint
RUN chmod +x /usr/local/bin/testnet-entrypoint

EXPOSE 5259 5260 5261

CMD ["activeledger"]
