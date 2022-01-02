FROM alpine:latest AS builder
COPY . /radiator
WORKDIR /radiator
RUN apk add --update alpine-sdk automake autoconf
RUN aclocal && autoconf && automake --add-missing
RUN ./configure --prefix=/usr/local && make && make install

FROM builder
COPY --from=builder /usr/local/bin/radiator /usr/local/bin/radiator
COPY --from=builder /radiator/release /radiator/release
WORKDIR /radiator
ENV RADIATOR_MQTT_BROKER_ADDRESS localhost
ENV RADIATOR_MQTT_BROKER_PORT 1883
ENV RADIATOR_MQTT_PUBLISH_TOPIC radiator
ENV RADIATOR_MQTT_MIN_PUBLISH_INTERVAL 10
RUN apk add --update python3 py3-pip && pip install paho-mqtt && chmod +x /radiator/release/bin/radiator_mqtt.py
CMD radiator -D3 -o >(/radiator/release/bin/radiator_mqtt.py) /dev/ttyS0