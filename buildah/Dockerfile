FROM quay.io/buildah/stable
LABEL org.opencontainers.image.authors="Bryce Han"

ENV STORAGE_DRIVER=vfs
ENV HARBOR_URL=core.harbor.brycehan.com
ENV HARBOR_USERNAME=admin

COPY password.txt /password.txt
COPY buildah.sh /buildah.sh

USER root

RUN chmod +x /buildah.sh
