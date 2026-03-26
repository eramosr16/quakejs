# Build stage: compile ioquake3 to JavaScript using Emscripten
FROM emscripten/emsdk:latest AS builder

RUN apt-get update && apt-get install -y \
    git \
    make \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone https://github.com/inolen/ioq3.git ioq3

RUN cd ioq3 && make PLATFORM=js EMSCRIPTEN= \
    && ls build/release-js-js/ioq3ded.js build/release-js-js/ioquake3.js

# Runtime stage
FROM node:20-slim

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

# Copy built binaries and associated WebAssembly files from the build stage
COPY --from=builder /build/ioq3/build/release-js-js/ ./build/

EXPOSE 8080 9000 27950

CMD ["node", "bin/web.js"]
