# Download
FROM inutano/wget AS downloader

RUN wget -O wla-dx.tar https://github.com/vhelin/wla-dx/tarball/master --progress=dot \
    && mkdir wla-dx \
    && tar -C wla-dx --strip-components=1 -xf wla-dx.tar


# Build
FROM debian:buster AS builder

RUN apt-get update \
    && apt-get install --assume-yes build-essential cmake libpng-dev zlib1g zlib1g-dev

COPY --from=downloader /wla-dx /usr/src/wla-dx

RUN cd /usr/src/wla-dx \
    && mkdir build && cd build && cmake .. \
    && cmake --build . -- -j$(nproc --all) \
    && cmake -P cmake_install.cmake


# Final image
FROM debian:buster

RUN apt-get update \
    && apt-get install --assume-yes libpng-dev zlib1g

COPY --from=builder /usr/local/bin/wla-* /usr/local/bin/wlalink /usr/local/bin/wlab /usr/local/bin/
