FROM pistacks/alpine:3.11.3 as builder

WORKDIR /tmp

RUN wget https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-armv7.tar.gz

RUN tar -xf prometheus-2.15.2.linux-armv7.tar.gz && cd prometheus-2.15.2.linux-armv7 && find . \
    && mkdir -p /usr/share/prometheus /etc/prometheus \
    && mv console_libraries /usr/share/prometheus/console_libraries \
    && mv consoles /usr/share/prometheus/consoles \
    && mv prometheus.yml /etc/prometheus/prometheus.yml \
    && mv prometheus /bin/prometheus \
    && mv tsdb /bin/tsdb \
    && mv promtool /bin/promtool

FROM busybox

COPY --from=builder /usr/share/prometheus/console_libraries /usr/share/prometheus/console_libraries
COPY --from=builder /usr/share/prometheus/consoles /usr/share/prometheus/consoles
COPY --from=builder /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
COPY --from=builder /bin/prometheus /bin/prometheus
COPY --from=builder /bin/tsdb /bin/tsdb
COPY --from=builder /bin/promtool /bin/promtool

RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/

RUN mkdir -p /prometheus && \
    chown -R nobody:nogroup etc/prometheus /prometheus

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
