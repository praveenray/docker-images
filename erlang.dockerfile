FROM ubuntu:latest AS build
RUN apt-get update -y

RUN apt install pkg-config unixodbc-dev build-essential libssl-dev openssl git curl file xz-utils libncurses-dev default-jdk perl-base -y
WORKDIR /software

RUN curl -k -L -o otp_src_27.tar.gz  https://github.com/erlang/otp/releases/download/OTP-27.0/otp_src_27.0.tar.gz && \
    tar zxf otp_src_27.tar.gz && \
    cd otp_src_27.0 && \
    export ERL_TOP=/software/otp_src_27.0 && \
    export LANG=C && \
    export JAVA_HOME=/usr/lib/jvm/default-java && \
    ./configure --prefix=/opt/erlang && \
    make --jobs=$(nproc) && \
    make install
RUN ls -l /opt/

FROM ubuntu
COPY --from=build /opt/erlang /opt/erlang
RUN echo "export PATH=$PATH:/opt/erlang/bin" >> ~/.bashrc
RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
ENTRYPOINT ["tail", "-f", "/dev/null"]

# This docker image builds specific version of erlang on Ubuntu. Erlang official releases are few versions behind and
# building from source is the only way to get latest.
# Also, you don't want to install bunch of packages on your host system simply to compile. Once this image is built
# and container is run, you can simply copy /opt/erlang to your host's /opt/erlang and run erlang from there.

# docker build -t erlang:27 -f erlang.dockerfile .
# docker run --rm --name erlang -d -v /home/daisy/projects/erlang:/erlang -t erlang:27
# docker exec -it erlang bash
# Alternately, copy final built artifacts:  `docker cp erlang:/opt/erlang /opt`
#  Note that it must be copied to hosts /opt/erlang since this path is hardcoded in the artifacts
