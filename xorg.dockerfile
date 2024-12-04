FROM ubuntu
ENV DEBIAN_INTERACTIVE=non-interactive
RUN apt-get update -y
RUN apt-get install xterm curl -y
ENTRYPOINT ["tail", "-f", "/dev/null"]

# use this docker image to run X software inside a docker image.
# docker build -t ubuntu:xorg -f xorg.dockerfile .
# xhost +  <-- run on host
# docker run --rm -d --name xorgcontainer -eDISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -t ubuntu:xorg
# Now you can shell into docker container and run your favourite X programs
# docker exec -it xorgcontainer bash
# xterm

