FROM quay.io/buildah/stable
LABEL org.opencontainers.image.authors="Bryce Han"

ENV STORAGE_DRIVER=vfs
ENV HARBOR_URL=core.harbor.brycehan.com
ENV HARBOR_USERNAME=admin
ENV HARBOR_PASSWORD=Harbor12345

COPY password.txt /password.txt

# RUN cat /password.txt | buildah login -u admin --password-stdin core.harbor.brycehan.com --tls-verify=false
