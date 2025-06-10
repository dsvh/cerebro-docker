FROM openjdk:11-jre-slim as builder

ARG CEREBRO_VERSION=0.9.4

RUN  apt-get update \
 && apt-get install -y wget \
 && mkdir -p /opt/cerebro/logs \
 && wget -qO- https://github.com/lmenezes/cerebro/releases/download/v${CEREBRO_VERSION}/cerebro-${CEREBRO_VERSION}.tgz \
  | tar xzv --strip-components 1 -C /opt/cerebro \
 && sed -i '/<appender-ref ref="FILE"\/>/d' /opt/cerebro/conf/logback.xml

# RUN apt-get update && apt-get install -y --only-upgrade zlib1g openssl libdb5.3 dpkg libc6 libgnutls30 liblz4-1 libtasn1-6 libpcre2-8-0
RUN apt-get update && apt-get install -y --only-upgrade zlib1g && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM openjdk:11-jre-slim

COPY --from=builder /opt/cerebro /opt/cerebro

RUN addgroup -gid 1000 cerebro \
 && adduser -q --system --no-create-home --disabled-login -gid 1000 -uid 1000 cerebro \
 && chown -R root:root /opt/cerebro \
 && chown -R cerebro:cerebro /opt/cerebro/logs \
 && chown cerebro:cerebro /opt/cerebro

WORKDIR /opt/cerebro
USER cerebro

ENTRYPOINT [ "/opt/cerebro/bin/cerebro" ]
