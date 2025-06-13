FROM openjdk:11-jre-slim as builder

ARG CEREBRO_VERSION=0.9.4

RUN  apt-get update \
 && apt-get install -y wget \
 && mkdir -p /opt/cerebro/logs \
 && wget -qO- https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
  | tar xzv --strip-components 1 -C /opt/cerebro \
 && sed -i '/<appender-ref ref="FILE"\/>/d' /opt/cerebro/conf/logback.xml


FROM openjdk:11-jre-slim

RUN apt-get update \
    && apt-get install -y --only-upgrade openssl libdb5.3 dpkg libc6 libgnutls30 liblz4-1 \
    && apt-get install -y \
        zlib1g=1:1.2.11.dfsg-2+deb11u2 \
        libkrb5-3=1.18.3-6+deb11u5 \
        libpcre2-8-0=10.36-2+deb11u1 \
        libtasn1-6=4.16.0-2+deb11u1 \
    && apt-mark hold \
        zlib1g \
        libkrb5-3 \
        libpcre2-8-0 \
        libtasn1-6
        
COPY --from=builder /opt/cerebro /opt/cerebro

RUN addgroup -gid 1000 cerebro \
 && adduser -q --system --no-create-home --disabled-login -gid 1000 -uid 1000 cerebro \
 && chown -R root:root /opt/cerebro \
 && chown -R cerebro:cerebro /opt/cerebro/logs \
 && chown cerebro:cerebro /opt/cerebro

WORKDIR /opt/cerebro
USER cerebro

ENTRYPOINT [ "/opt/cerebro/bin/cerebro" ]
