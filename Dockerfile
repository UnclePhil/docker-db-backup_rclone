ARG VERSION="0.0.0"
ARG SRC_IMG="tiredofit/db-backup:3.6.1"

FROM ${SRC_IMG}

LABEL modifier="Ph Koenig (github.com/unclephil)"
LABEL appname="docker-db-backup-rclone"
LABEL version=${VERSION}

### PKO  Setup overwrite
RUN set -ex && \    
    apk add --no-cache  \
            rclone

COPY install  /