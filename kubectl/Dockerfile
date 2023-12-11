FROM docker.io/bitnami/kubectl:1.26
LABEL org.opencontainers.image.authors="Bryce Han"

COPY deployment.yaml /opt/deployment.yaml
COPY service.yaml /opt/service.yaml
COPY ingress.yaml /opt/ingress.yaml
COPY patch.yaml /opt/patch.yaml
COPY deploy.sh /deploy.sh
USER root
RUN chmod +x /deploy.sh

ENTRYPOINT []
