FROM rockylinux:8.8 AS base
SHELL ["/bin/bash", "-c"]
WORKDIR /workdir
RUN yum update -y && \
    yum clean all -y

FROM base AS build_libdragon_toolchain
ENV N64_INST="/opt/libdragon"
ENV LIBDRAGON_COMMIT="fe168f22058faf11a9655867b6698191f3c59e69"
RUN yum install -y \
        gcc \
        gcc-c++ \
        git \
        make \
        sudo \
        wget && \
    yum clean all -y && \
    wget https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.rpm && \
    rpm -ivh gcc-toolchain-mips64-x86_64.rpm && \
    git clone https://github.com/DragonMinded/libdragon && \
    pushd ./libdragon && \
    git checkout -f $LIBDRAGON_COMMIT && \
    ./build.sh && \
    popd

FROM base AS build_riscv_toolchain
ENV RISCV_TOOLCHAIN_COMMIT="tags/2024.08.06"
RUN yum install -y dnf-plugins-core && \
    yum config-manager --set-enabled powertools && \
    yum install -y \
        autoconf \
        automake \
        bison \
        expat-devel \
        flex \
        gawk \
        gcc \
        gcc-c++ \
        git \
        gmp-devel \
        libmpc-devel \
        libslirp-devel \
        make \
        mpfr-devel \
        patchutils \
        python3 \
        texinfo \
        zlib-devel && \
    git clone https://github.com/riscv/riscv-gnu-toolchain && \
    pushd ./riscv-gnu-toolchain && \
    git checkout -f $RISCV_TOOLCHAIN_COMMIT && \
    ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32 --disable-gdb && \
    make -j && \
    popd && \
    rm -rf ./riscv-gnu-toolchain

FROM base AS release
ENV N64_INST="/usr/local"
ENV DIAMOND_DIR="/usr/local/diamond/3.13"
ENV bindir="$DIAMOND_DIR/bin/lin64"
ENV LM_LICENSE_FILE="/flexlm/license.dat"
COPY ./requirements.txt ./tmp/requirements.txt
RUN yum install -y \
        fontconfig \
        freetype \
        glib2 \
        glibc \
        gstreamer1-plugins-base \
        libICE \
        libjpeg \
        libtiff \
        libuuid \
        libX11 \
        libXcomposite \
        libXext \
        libXft \
        libXi \
        libXrender \
        libXt \
        mesa-libGL && \
    yum install -y \
        bc \
        git \
        libmpc \
        make \
        python3 \
        wget \
        zip && \
    yum clean all -y && \
    mkdir -p ./tmp && \
    pushd ./tmp && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r ./requirements.txt && \
    wget https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar -xf arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz && \
    cp -r ./arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/* /usr/local/ && \
    wget https://files.latticesemi.com/Diamond/3.13/diamond_3_13-base-56-2-x86_64-linux.rpm && \
    rpm -ivh diamond_3_13-base-56-2-x86_64-linux.rpm && \
    popd && \
    rm -rf ./tmp && \
    mkdir -p /flexlm
COPY --from=build_libdragon_toolchain /opt/libdragon /usr/local
COPY --from=build_riscv_toolchain /opt/riscv /usr/local
