FROM docker.artifactory.sherwin.com/alpine:3.15

ENV BASE_URL="https://get.helm.sh"

ENV HELM_2_FILE="helm-v2.17.0-linux-amd64.tar.gz"
ENV HELM_3_FILE="helm-v3.8.1-linux-amd64.tar.gz"

# Add the Sherwin Root Cert
USER root
ADD http://swroot.sherwin.com/swroot.pem /usr/local/share/ca-certificates/swroot.crt
# Update the certificates
RUN apk add --no-cache ca-certificates
RUN chmod 444 /usr/local/share/ca-certificates/swroot.crt

ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/swroot.crt

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    jq curl bash nodejs && \
    # Install helm version 2:
    curl -L ${BASE_URL}/${HELM_2_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    # Install helm version 3:
    curl -L ${BASE_URL}/${HELM_3_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm3 && \
    chmod +x /usr/bin/helm3 && \
    rm -rf linux-amd64 && \
    # Init version 2 helm:
    helm init --client-only

ENV PYTHONPATH "/usr/lib/python3.8/site-packages/"

# Handle AWS CLI setup
RUN apk add --no-cache \
    python3 \
    py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

COPY . /usr/src/
ENTRYPOINT ["node", "/usr/src/index.js"]
