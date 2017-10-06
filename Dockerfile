FROM gn00023040/oracle-java-8-ubuntu-slim:8u144

ARG CASSANDRA_VERSION
ARG CASSANDRA_SHA1
ARG DEV_CONTAINER

LABEL maintainer="Jimmy Lu <gn00023040@gmail.com>"

ENV CASSANDRA_HOME=/usr/local/apache-cassandra-${CASSANDRA_VERSION} \
    CASSANDRA_CONF=/etc/cassandra \
    CASSANDRA_LOGS=/var/log/cassandra \
    PATH=${PATH}:/usr/local/apache-cassandra-${CASSANDRA_VERSION}/bin \
    DI_VERSION=1.2.0 \
    DI_SHA=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

RUN set -e \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get -qq -y --force-yes install wget libjemalloc1 localepurge \
    && wget -q -O /tmp/cassandra.tar.gz http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
    && echo "${CASSANDRA_SHA1} /tmp/cassandra.tar.gz" | sha1sum -c - \
    && tar -xzf /tmp/cassandra.tar.gz -C /usr/local \
    && wget -q -O - https://github.com/Yelp/dumb-init/releases/download/v${DI_VERSION}/dumb-init_${DI_VERSION}_amd64 > /sbin/dumb-init \
    && echo "$DI_SHA  /sbin/dumb-init" | sha256sum -c - \
    && chmod +x /sbin/dumb-init \
    && mkdir -p $CASSANDRA_CONF \
    && cp \
            $CASSANDRA_HOME/conf/cassandra.yaml \
            $CASSANDRA_HOME/conf/cassandra-env.sh \
            $CASSANDRA_HOME/conf/cassandra-rackdc.properties \
            $CASSANDRA_HOME/conf/cassandra-topology.properties \
            $CASSANDRA_HOME/conf/commitlog_archiving.properties \
            $CASSANDRA_HOME/conf/hotspot_compiler \
            $CASSANDRA_HOME/conf/jvm.options \
            $CASSANDRA_HOME/conf/logback.xml \
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

VOLUME ["/var/lib/cassandra"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

CMD ["/sbin/dumb-init", "/bin/bash", "${CASSANDRA_HOME}/bin/cassandra"]
