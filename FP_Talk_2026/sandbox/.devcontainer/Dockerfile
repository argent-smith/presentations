FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Базовые пакеты + OCaml + Python
RUN apt-get update && apt-get install -y \
    ocaml \
    python3 \
    curl \
    ca-certificates \
    make \
    && rm -rf /var/lib/apt/lists/*

# Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# scala-cli
RUN curl -fL https://github.com/VirtusLab/scala-cli/releases/latest/download/scala-cli-x86_64-pc-linux.gz \
    | gzip -d > /usr/local/bin/scala-cli \
    && chmod +x /usr/local/bin/scala-cli

# Rust (rustup + cargo, минимальный профиль)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --profile minimal \
    && chmod -R a+w /usr/local/rustup /usr/local/cargo

WORKDIR /sandbox
