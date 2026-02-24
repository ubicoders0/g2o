ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common && \
    if [ "$(cat /etc/os-release | grep VERSION_ID | cut -d '"' -f 2)" = "20.04" ]; then \
    apt-get install -y wget build-essential libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev libffi-dev && \
    wget https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tgz && \
    tar -xf Python-3.10.14.tgz && \
    cd Python-3.10.14 && \
    ./configure && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && rm -rf Python-3.10.14 Python-3.10.14.tgz && \
    ln -sf /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3; \
    else \
    apt-get install -y python3 python3-pip python3-venv; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Create a virtual environment and update pip
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip

# Install the package from PyPI
RUN pip install ubicoders-g2opy

# Copy the tester script into the container
WORKDIR /app
COPY tester.py .

# Command to run the tester script
CMD ["python", "tester.py"]
