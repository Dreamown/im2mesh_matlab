FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install the C++ build tools and math libraries
RUN apt-get update && apt-get -y install \
	libeigen3-dev \
	libgmp-dev \
	libgmpxx4ldbl \
	libmpfr-dev \
	git \
	make \
	cmake \
	gcc \
	g++ \
	&& rm -rf /var/lib/apt/lists/*

# Clone and build fTetWild
RUN git clone https://github.com/wildmeshing/fTetWild.git && \
	cd fTetWild && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make