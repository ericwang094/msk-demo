FROM ubuntu

RUN apt update -y && \
    apt install -y \
    python3 python3-pip wget && \
    pip3 install boto3

ARG PROM_DOWNLOAD=https://github.com/prometheus/prometheus/releases/download/v2.19.2/prometheus-2.19.2.linux-amd64.tar.gz

RUN mkdir /etc/prometheus && \
    mkdir /var/lib/prometheus && \
    mkdir -p /prometheus && \
    wget -P /tmp/ ${PROM_DOWNLOAD} && \
    cd /tmp/ && \
    tar xf prom*.tar.gz && \
    cp prom*/prometheus /usr/local/bin/ && \
    cp prom*/promtool /usr/local/bin/ && \
    cp -r prom*/consoles /etc/prometheus/ && \
    cp -r prom*/console_libraries /etc/prometheus/

ENV REGION=
ENV CLUSTER_ARN=

COPY ./prometheus.yml /etc/prometheus/
COPY ./generate_targets.py /etc/prometheus/
COPY ./init.sh /

EXPOSE 9090
VOLUME [ "/prometheus" ]
WORKDIR /prometheus

CMD /init.sh