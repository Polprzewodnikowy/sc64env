FROM centos:7.9.2009 as base
SHELL ["/bin/bash", "-c"]
WORKDIR /workdir
RUN yum update -y && \
    yum clean all -y


FROM base as build_n64
ENV N64_INST="/opt/n64"
RUN yum install -y \
        centos-release-scl-rh \
        git \
        gmp-devel \
        libmpc-devel \
        libpng-devel \
        make \
        mpfr-devel \
        texinfo \
        zlib-devel && \
    yum install -y devtoolset-11-toolchain && \
    git clone https://github.com/DragonMinded/libdragon && \
    pushd ./libdragon && \
    git checkout -f b242d719ee1b75976c6a5be3f02db4d191ecbd77 && \
    pushd ./tools && \
    scl enable devtoolset-11 ./build-toolchain.sh && \
    popd && \
    scl enable devtoolset-11 ./build.sh && \
    popd


FROM base as release
ENV LM_LICENSE_FILE="/flexlm/license.dat"
ENV DIAMOND_DIR="/usr/local/diamond/3.12"
ENV bindir="$DIAMOND_DIR/bin/lin64"
ENV N64_INST="/usr/local"
RUN yum install -y \
        bzip2 \
        csh \
        libmpc \
        make \
        mpfr \
        perl \
        zip \
        glibc \
        libjpeg \
        libtiff \
        glib2 \
        libusb \
        freetype \
        fontconfig \
        libX11 \
        libICE \
        libuuid \
        libXt \
        libXext \
        libXrender \
        libXi \
        libXft && \
    yum clean all -y && \
    mkdir -p ./tmp && \
    pushd ./tmp && \
    curl http://files.latticesemi.com/Diamond/3.12/diamond_3_12-base-240-2-x86_64-linux.rpm --output diamond_3_12-base-240-2-x86_64-linux.rpm && \
    curl http://files.latticesemi.com/Diamond/3.12.1/diamond_3_12-sp1-454-2-x86_64-linux.rpm --output diamond_3_12-sp1-454-2-x86_64-linux.rpm && \
    curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 --output gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    rpm -ivh diamond_3_12-base-240-2-x86_64-linux.rpm && \
    rpm -ivh diamond_3_12-sp1-454-2-x86_64-linux.rpm && \
    tar -xf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    cp -r ./gcc-arm-none-eabi-10.3-2021.10/* /usr/local/ && \
    popd && \
    rm -rf ./tmp && \
    mkdir -p /flexlm && \
    echo "source \$bindir/diamond_env" >> /etc/bashrc
COPY --from=build_n64 /opt/n64 /usr/local
