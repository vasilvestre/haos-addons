# Two stages so the dashboard binary comes from the project's own image,
# pinned per version, and the app still gets a shell: the upstream image is
# distroless and cannot read its options or write a secret.
ARG BUILD_FROM
ARG UPSTREAM_IMAGE=ghcr.io/alteredparadox/pmss-fleet-manager:1.24.0

FROM ${UPSTREAM_IMAGE} AS upstream

FROM ${BUILD_FROM}

COPY --from=upstream /pmss-fleet-manager /usr/bin/pmss-fleet-manager

COPY run.sh /run.sh
RUN chmod 755 /run.sh /usr/bin/pmss-fleet-manager

CMD ["/run.sh"]
