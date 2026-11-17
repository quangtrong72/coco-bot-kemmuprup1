FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-21-jre-headless \
    xvfb \
    xdotool \
    x11-utils \
    python3 \
    python3-pip \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages portablemc

WORKDIR /app

COPY game_data /app/game_data
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
