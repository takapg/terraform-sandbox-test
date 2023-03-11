FROM ubuntu:22.04

ARG TFLOCAL_VERSION=0.6

WORKDIR /work

ENV PATH="/root/.local/share/aquaproj-aqua/bin:$PATH"

RUN apt-get update -y && \
    apt-get install -y curl unzip less jq vim git python3 python3-pip && \
    pip3 install terraform-local==${TFLOCAL_VERSION} && \
    curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.0.2/aqua-installer && \
    echo "acbb573997d664fcb8df20a8a5140dba80a4fd21f3d9e606e478e435a8945208  aqua-installer" | sha256sum -c && \
    chmod +x aqua-installer && \
    ./aqua-installer && \
    rm aqua-installer

COPY ./aqua.yaml ./aqua.yaml

RUN aqua i -l && \
    echo 'alias aws="aws --endpoint-url http://localstack:4566"' >> ~/.bashrc && \
    echo 'alias terraform="tflocal"' >> ~/.bashrc && \
    echo "plugin_cache_dir = \"$HOME/.terraform.d/plugin-cache\"" > "$HOME/.terraformrc" && \
    mkdir -p $HOME/.terraform.d/plugin-cache
