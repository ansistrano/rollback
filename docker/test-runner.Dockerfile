FROM python:3.12-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        rsync \
        sudo \
    && python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir ansible-core \
    && ansible-galaxy collection install ansible.posix \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 docker/run-tests.sh /usr/local/bin/run-ansistrano-tests

WORKDIR /workspace/rollback
ENTRYPOINT ["run-ansistrano-tests"]
