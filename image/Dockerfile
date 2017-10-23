FROM gn00023040/oracle-java-8-ubuntu-slim:8u152

ARG CASSANDRA_VERSION=3.0.9
ARG DEV_CONTAINER=false

LABEL maintainer="Jimmy Lu <gn00023040@gmail.com>"

ENV CASSANDRA_HOME=/usr/local/apache-cassandra-${CASSANDRA_VERSION} \
    CASSANDRA_CONF=/etc/cassandra \
    CASSANDRA_DATA=/cassandra/data \
    PATH=${PATH}:/usr/local/apache-cassandra-${CASSANDRA_VERSION}/bin \
    DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

ADD files /

RUN set -e \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get -qq -y --force-yes install wget libjemalloc1 localepurge \
    && wget -q -O /tmp/cassandra.tar.gz http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
    && wget -q -O /tmp/cassandra.tar.gz.asc http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz.asc \
    && wget -q -O /tmp/KEYS http://archive.apache.org/dist/cassandra/KEYS \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --import /tmp/KEYS \
    && gpg --batch --verify "/tmp/cassandra.tar.gz.asc" "/tmp/cassandra.tar.gz" \
    && tar -xzf /tmp/cassandra.tar.gz -C /usr/local \
    && chmod +x /ready-probe.sh \
    && mkdir -p $CASSANDRA_CONF \
    && mv /cassandra.yaml /cassandra-env.sh /logback.xml $CASSANDRA_CONF \
    && cp \
       $CASSANDRA_HOME/conf/jvm.options \
       $CASSANDRA_HOME/conf/hotspot_compiler \
       $CASSANDRA_HOME/conf/commitlog_archiving.properties \
       $CASSANDRA_CONF \
    && adduser --disabled-password --no-create-home --gecos '' --disabled-login cassandra \
    && if [ -n "$DEV_CONTAINER" ]; then apt-get -y --no-install-recommends install python; else rm -rf  $CASSANDRA_HOME/pylib; fi \
    && apt-get -y purge wget localepurge \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf \
            $CASSANDRA_HOME/*.txt \
            $CASSANDRA_HOME/doc \
            $CASSANDRA_HOME/javadoc \
            $CASSANDRA_HOME/tools/*.yaml \
            $CASSANDRA_HOME/tools/bin/*.bat \
            $CASSANDRA_HOME/bin/*.bat \
            $CASSANDRA_HOME/conf \
        doc \
        man \
        info \
        locale \
        common-licenses \
        ~/.bashrc \
            /var/lib/apt/lists/* \
            /var/log/* \
            /var/cache/debconf/* \
            /etc/systemd \
            /lib/lsb \
            /lib/udev \
            /usr/share/doc/ \
            /usr/share/doc-base/ \
            /usr/share/man/ \
            /tmp/*

VOLUME ["/cassandra/data"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

CMD ["/sbin/dumb-init", "/bin/bash", "run.sh"]
