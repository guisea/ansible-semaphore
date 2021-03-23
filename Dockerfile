FROM frolvlad/alpine-glibc:alpine-3.10 as builder
ENV ANSIBLE_VERSION="2.9.19"
ENV SEMAPHORE_VERSION="2.6.8"

USER root

COPY install.sh /tmp
COPY semaphore-wrapper /usr/local/bin/semaphore-wrapper

RUN apk --no-cache add \
        python3\
        py3-pip \
        py3-cryptography \
        openssl \
        ca-certificates \
        sshpass && \
        git && \
        curl && \
        mysql-client && \
        openssh-client && \
        tini && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip3 install --no-cache-dir --upgrade pip cffi && \
    pip3 install --no-cache-dir ansible==${ANSIBLE_VERSION} && \
    pip3 install --no-cache-dir mitogen ansible-lint jmespath && \
    pip3 install --no-cache-dir --upgrade pywinrm pyVmomi ovh requests && \
    apk del build-dependencies && \
    pip3 cache purge && \
    rm -rf /var/cache/apk/* && \
    sh /tmp/install.sh ${SEMAPHORE_VERSION} && \
    adduser -D -u 1001 -G root semaphore && \
    mkdir -p /tmp/semaphore && \
    mkdir -p /etc/semaphore && \
    chown -R semaphore:0 /tmp/semaphore && \
    chown -R semaphore:0 /etc/semaphore && \
    chmod a+x /usr/local/bin/semaphore-wrapper && \
    chown -R semaphore:0 /usr/local/bin/semaphore-wrapper &&\
    chown -R semaphore:0 /usr/local/bin/semaphore 



FROM scratch as final

COPY --from=builder / /

WORKDIR /home/semaphore
USER 1001

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/semaphore-wrapper", "/usr/local/bin/semaphore", "--config", "/etc/semaphore/config.json"]