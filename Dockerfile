FROM tiredofit/db-backup:latest

LABEL modifier="Ph Koenig (github.com/unclephil)"  

### PKO  Setup overwrite
RUN set -ex && \    
    apk add --no-cache -t .db-backup-run-deps \
            rclone

COPY install  /