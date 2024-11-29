FROM ubuntu
ENV DEBIAN_INTERACTIVE=non-interactive
RUN apt-get update -y
RUN apt-get install xterm curl -y
ENTRYPOINT ["tail", "-f", "/dev/null"]

# docker build -t ubuntu:xorg -f xorg.dockerfile .
# xhost+  <-- run on host
# docker run --rm -d --name xorgcontainer -eDISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -t ubuntu:xorg
