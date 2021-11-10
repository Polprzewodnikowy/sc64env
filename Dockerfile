FROM ubuntu:18.04 AS base


FROM base AS build_base
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/scratchpad
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        autoconf \
        automake \
        autotools-dev \
        bc \
        bison \
        build-essential \
        bzip2 \
        curl \
        expect \
        file \
        flex \
        g++ \
        gawk \
        gcc \
        gcc-multilib \
        git \
        gperf \
        libexpat-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libpng-dev \
        libtool \
        make \
        patchutils \
        python3 \
        texinfo \
        texinfo \
        wget \
        zlib1g-dev


FROM build_base AS build_riscv
RUN git clone --branch 2021.09.21 https://github.com/riscv/riscv-gnu-toolchain && \
    pushd ./riscv-gnu-toolchain && \
    ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32 && \
    make -j$(nproc) && \
    popd && \
    rm -rf ./riscv-gnu-toolchain


FROM build_base AS build_n64
ENV N64_INST=/opt/n64
ENV FORCE_DEFAULT_GCC=true
RUN git clone https://github.com/DragonMinded/libdragon && \
    pushd ./libdragon && \
    git checkout 4d58607b34ba4139567055a4ec460937dc8b09b0 && \
    pushd ./tools && \
    ./build-toolchain.sh && \
    popd && \
    ./build.sh && \
    popd && \
    rm -rf ./libdragon


FROM build_base AS build_quartus
ADD setup_quartus.sh .
RUN mkdir -p ./quartus && \
    pushd ./quartus && \
    wget -q http://download.altera.com/akdlm/software/acdsinst/21.1std/842/ib_tar/Quartus-lite-21.1.0.842-linux.tar && \
    tar xvf Quartus-lite-21.1.0.842-linux.tar && \
    popd && \
    ./setup_quartus.sh && \
    rm -rf ./quartus setup_quartus.sh


FROM base AS release
WORKDIR /workdir
ENV DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL="en_US.UTF-8"
ENV N64_INST="/usr/local"
ENV PATH="${PATH}:/opt/intel/quartus/bin"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y avra binutils make python3 libglib2.0-0 libtcmalloc-minimal4 libmpc3 locales zip && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
COPY --from=build_riscv /opt/riscv /usr/local
COPY --from=build_n64 /opt/n64 /usr/local
COPY --from=build_quartus /opt/intel /opt/intel
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
