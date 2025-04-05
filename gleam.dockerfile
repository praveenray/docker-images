FROM rust:latest
WORKDIR /opt

RUN git clone https://github.com/gleam-lang/gleam.git \
&& cd /opt/gleam \
&& git checkout v1.9.1 \
&& make install \
&& cp /usr/local/cargo/bin/gleam /opt/gleam

# docker build -t gleam:1.9.1 -f gleam.dockerfile .
