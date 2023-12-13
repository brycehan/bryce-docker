FROM docker.io/bitnami/kubectl:1.26
LABEL org.opencontainers.image.authors="Bryce Han"

COPY deployment.yaml /deployment.yaml
COPY service.yaml /service.yaml
COPY ingress.yaml /ingress.yaml
COPY patch.yaml /patch.yaml
COPY deploy.sh /deploy.sh

USER root
RUN chmod +x /deploy.sh

ENTRYPOINT []
