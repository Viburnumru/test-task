# Используем официальный образ Ubuntu 22.04
FROM ubuntu:22.04

# Установка общих пакетов
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

# Установка libdeflate v1.18
RUN wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.18.tar.gz && \
    echo "Downloaded libdeflate v1.18.tar.gz" && \
    tar -xzf v1.18.tar.gz && \
    cd libdeflate-1.18 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install PREFIX=/soft/libdeflate-1.18 && \
    rm -rf /soft/v1.18.tar.gz /soft/libdeflate-1.18

# Установка samtools v1.16.1
RUN wget https://github.com/samtools/samtools/releases/download/1.16.1/samtools-1.16.1.tar.bz2 && \
    echo "Downloaded samtools v1.16.1" && \
    tar -xjf samtools-1.16.1.tar.bz2 && \
    cd samtools-1.16.1 && \
    make -j4 && \
    make install PREFIX=/soft/samtools-1.16.1 && \
    rm -rf /soft/samtools-1.16.1.tar.bz2 /soft/samtools-1.16.1

# Установка bcftools v1.16
RUN wget https://github.com/samtools/bcftools/releases/download/1.16/bcftools-1.16.tar.bz2 && \
    echo "Downloaded bcftools v1.16" && \
    tar -xjf bcftools-1.16.tar.bz2 && \
    cd bcftools-1.16 && \
    make -j4 && \
    make install PREFIX=/soft/bcftools-1.16 && \
    rm -rf /soft/bcftools-1.16.tar.bz2 /soft/bcftools-1.16

# Установка vcftools v0.1.16
RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
    echo "Downloaded vcftools v0.1.16" && \
    tar -xzf vcftools-0.1.16.tar.gz && \
    cd vcftools-0.1.16 && \
    ./autogen.sh && \
    ./configure && \
    make -j4 && \
    make install PREFIX=/soft/vcftools-0.1.16 && \
    rm -rf /soft/vcftools-0.1.16.tar.gz /soft/vcftools-0.1.16

# Копирование Python скрипта в контейнер
COPY ./convert_format.py /soft/convert_format.py

# Установка зависимостей Python (если есть файл requirements.txt)
COPY ./requirements.txt /soft/requirements.txt
RUN pip3 install --no-cache-dir -r /soft/requirements.txt

# Очистка ненужных файлов
RUN rm -rf /var/lib/apt/lists/*

# Установка переменных окружения
ENV PATH="$PATH:/soft/libdeflate-1.18/bin:/soft/samtools-1.16.1/bin:/soft/bcftools-1.16/bin:/soft/vcftools-0.1.16/bin"

# Установка рабочей директории
WORKDIR /soft

