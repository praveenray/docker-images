FROM ubuntu:jammy AS build
ENV DEBIAN_INTERACTIVE=non-interactive

RUN apt-get update -y
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN DEBIAN_INTERACTIVE=non-interactive apt install pkg-config unzip build-essential tcl-dev libssl-dev openssl git curl file xz-utils libncurses-dev default-jdk perl-base -y
WORKDIR /software

RUN curl -o sqlite.tar.gz "https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release"

RUN tar zxf sqlite.tar.gz

RUN mkdir bld && \
    cd bld && \
    ../sqlite/configure --enable-all --prefix=/opt/software/sqlite

RUN cd bld && make sqlite3
RUN cd bld && make sqldiff
RUN cd bld && make install

ENTRYPOINT ["tail", "-f", "/dev/null"]

# docker build -t sqlite -f sqlite.dockerfile .
# docker run --rm -d --name sqlite -t sqllite
# docker cp sqlite:/software/sqlite /opt
# docker stop sqlite
