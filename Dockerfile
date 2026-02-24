ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION}

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required C++ dependencies and tools
RUN apt-get update -qq && apt-get install -qqy \
    build-essential \
    cmake \
    make \
    git \
    patchelf \
    wget \
    curl \
    rsync \
    qtdeclarative5-dev \
    qt5-qmake \
    libqglviewer-dev-qt5 \
    libsuitesparse-dev \
    libeigen3-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/make /usr/bin/gmake

# Install Miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p ${CONDA_DIR} && \
    rm miniconda.sh

# Add conda to path
ENV PATH="${CONDA_DIR}/bin:${PATH}"

# Global Conda configuration
RUN conda config --set auto_activate_base false && \
    conda config --set always_yes yes && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# Initialize Conda for bash
RUN conda init bash

# Set up the working directory mapping
WORKDIR /app

# The entrypoint will be our build script
ENTRYPOINT ["/bin/bash", "/app/docker_runner.bash"]
