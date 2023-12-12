FROM rockylinux:8.8 as base
SHELL ["/bin/bash", "-c"]
WORKDIR /workdir
RUN yum update -y && \
    yum clean all -y

FROM base as toolchain_base
RUN yum install -y dnf-plugins-core && \
    yum config-manager --set-enabled powertools && \
    yum install -y \
        autoconf \
        automake \
        bison \
        bzip2 \
        expat-devel \
        flex \
        gawk \
        gcc-toolset-13-gcc \
        gcc-toolset-13-gcc-c++ \
        git \
        gmp-devel \
        libmpc-devel \
        libpng-devel \
        mpfr-devel \
        patchutils \
        python3 \
        texinfo \
        zlib-devel && \
    yum clean all -y

FROM toolchain_base as build_n64_toolchain
ENV N64_INST="/opt/n64"
RUN source scl_source enable gcc-toolset-13 && \
    git clone https://github.com/DragonMinded/libdragon && \
    pushd ./libdragon/tools && \
    ./build-toolchain.sh && \
    rm -rf ./toolchain && \
    popd

FROM build_n64_toolchain as build_n64_libdragon
ENV N64_INST="/opt/n64"
ENV LIBDRAGON_COMMIT="bcd85256afcb501950601f186e39482ad4e642bc"
RUN source scl_source enable gcc-toolset-13 && \
    pushd ./libdragon && \
    git fetch && \
    git checkout -f $LIBDRAGON_COMMIT && \
    ./build.sh && \
    popd

FROM toolchain_base as build_riscv_toolchain
ENV RISCV_TOOLCHAIN_COMMIT="tags/2023.11.22"
RUN source scl_source enable gcc-toolset-13 && \
    git clone https://github.com/riscv/riscv-gnu-toolchain && \
    pushd ./riscv-gnu-toolchain && \
    git checkout -f $RISCV_TOOLCHAIN_COMMIT && \
    ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32 --disable-gdb && \
    make -j16 && \
    popd && \
    rm -rf ./riscv-gnu-toolchain

FROM base as release
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
    wget https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar -xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    cp -r ./arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi/* /usr/local/ && \
    wget https://files.latticesemi.com/Diamond/3.13/diamond_3_13-base-56-2-x86_64-linux.rpm && \
    rpm -ivh diamond_3_13-base-56-2-x86_64-linux.rpm && \
    popd && \
    rm -rf ./tmp && \
    mkdir -p /flexlm
COPY --from=build_n64_libdragon /opt/n64 /usr/local
COPY --from=build_riscv_toolchain /opt/riscv /usr/local
