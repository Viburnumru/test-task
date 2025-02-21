# Используем официальный образ Ubuntu 22.04
FROM ubuntu:22.04

ENV SOFT="/soft"

RUN apt update && apt install -y \
    coreutils \
    build-essential \
    wget \
    tar \
    bzip2 \
    xz-utils \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    autoconf \
    automake \
    libtool \
    pkg-config \
    gcc \
    make \
    cmake \
    libncurses-dev \
    libboost-all-dev \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Установка libdeflate v1.23
RUN wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.23.tar.gz && \
    tar -xzf v1.23.tar.gz && \
    cd libdeflate-1.23 && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && \
    make DESTDIR=/soft/libdeflate-1.23 install && \ 
    rm -rf /v1.23.tar.gz /libdeflate-1.23


# Установка samtools v1.21
RUN wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 && \
    tar -xjf samtools-1.21.tar.bz2 && \
    cd samtools-1.21 && \
    ./configure --prefix=/soft/samtools-1.21 && \  
    make -j$(nproc) && \
    make install && \
    rm -rf /samtools-1.21.tar.bz2 /samtools-1.21


# Установка bcftools v1.18
RUN wget https://github.com/samtools/bcftools/releases/download/1.18/bcftools-1.18.tar.bz2 && \
    tar -xjf bcftools-1.18.tar.bz2 && \
    cd bcftools-1.18 && \
    ./configure --prefix=/soft/bcftools-1.18 && \ 
    make -j$(nproc) && \
    make install && \
    rm -rf /bcftools-1.18.tar.bz2 /bcftools-1.18


# Установка vcftools v0.1.16
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
    tar -xzf vcftools-0.1.16.tar.gz && \
    cd vcftools-0.1.16 && \
    ./autogen.sh && \
    ./configure --prefix=/soft/vcftools-0.1.16 && \ 
    make -j$(nproc) && \
    make install && \
    rm -rf /vcftools-0.1.16.tar.gz /vcftools-0.1.16

COPY ./convert_format.py /soft/convert_format.py

RUN rm -rf /var/lib/apt/lists/*

ENV PATH="/soft/libdeflate-1.23/bin:/soft/samtools-1.21/bin:/soft/bcftools-1.18/bin:/soft/vcftools-0.1.16/bin:$PATH"

ENV SAMTOOLS="${SOFT}/samtools-1.21/bin/samtools"
ENV BCFTOOLS="${SOFT}/bcftools-1.18/bin/bcftools"
ENV VCFTOOLS="${SOFT}/vcftools-0.1.16/bin/vcftools"




WORKDIR /soft
CMD ["bash"]
