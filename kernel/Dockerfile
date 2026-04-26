FROM debian:trixie

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

RUN apt-get update && apt-get install -y \
    build-essential \
    linux-source \
    bc \
    kmod \
    cpio \
    flex \
    libelf-dev \
    libssl-dev \
    dwarves \
    bison \
    debhelper-compat \
    gcc-riscv64-linux-gnu \
    libdw-dev \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    bash \
    libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${HOST_USER_UID} builder \
    && useradd --uid ${HOST_USER_GID} --gid builder --shell /bin/bash builder

RUN mkdir -p /kernel && chown -R ${HOST_USER_UID}:${HOST_USER_GID} /kernel
WORKDIR /kernel
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
RUN chown ${HOST_USER_UID}:${HOST_USER_GID} entrypoint.sh

USER ${HOST_USER_UID}:${HOST_USER_GID}

RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.19.13.tar.xz

ENTRYPOINT ["/bin/bash","entrypoint.sh"]
