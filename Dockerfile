FROM ansiblesemaphore/semaphore:v2.6.8

USER root

RUN apk del ansible && \
    apk --no-cache add \
        python3\
        py3-pip \
        py3-cryptography \
        openssl \
        ca-certificates \
        sshpass && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip3 install --no-cache-dir --upgrade pip cffi && \
    pip3 install --no-cache-dir ansible==2.9.19 && \
    pip3 install --no-cache-dir mitogen ansible-lint jmespath && \
    pip3 install --no-cache-dir --upgrade pywinrm pyVmomi ovh requests && \
    apk del build-dependencies && \
    pip3 cache purge && \
    rm -rf /var/cache/apk/*


WORKDIR /home/semaphore
USER 1001

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/semaphore-wrapper", "/usr/local/bin/semaphore", "--config", "/etc/semaphore/config.json"]