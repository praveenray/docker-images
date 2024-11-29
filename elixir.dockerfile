FROM erlang:27 AS build
RUN apt-get update -y
RUN apt-get install --no-install-recommends  curl unzip xz-utils -y
RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

WORKDIR /opt

RUN mkdir -p /opt && \
    curl -k -L -o /opt/node.tar.xz https://nodejs.org/dist/v20.15.0/node-v20.15.0-linux-x64.tar.xz && \
    xz -d /opt/node.tar.xz && \
    tar xf /opt/node.tar -C /opt && \
    mv /opt/node-v20* /opt/nodejs && \
    rm -f /opt/node.tar

RUN mkdir elixir && \
    curl -k -L -o elixir/elixir.zip https://github.com/elixir-lang/elixir/releases/download/v1.17.2/elixir-otp-27.zip && \
    cd elixir && \
    unzip elixir.zip && \
    rm -f elixir.zip

FROM erlang:27
RUN apt-get update -y
COPY --from=build /opt/nodejs /opt/nodejs
COPY --from=build /opt/elixir /opt/elixir

RUN apt-get install --no-install-recommends  locales -y
RUN echo "export LANG=en_US.UTF-8" >> ~/.update-locale && \
    echo "echo \$LANG UTF-8 > /etc/locale.gen" >> ~/.update-locale && \
    echo "locale-gen" >> ~/.update-locale && \
    echo "update-locale LANG=\$LANG" >> ~/.update-locale && \
    chmod +x ~/.update-locale && \
    echo "source ~/.update-locale" >> ~/.bashrc

RUN echo "export PATH=\$PATH:/opt/nodejs/bin" >> ~/.bashrc
RUN echo "export PATH=\$PATH:/opt/elixir/bin" >> ~/.bashrc
RUN echo "export PATH=\$PATH:/opt/erlang/bin" >> ~/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> ~/.bashrc

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["tail", "-f", "/dev/null"]

# docker build -t elixir:latest -f elixir.dockerfile .
# docker run --rm --name elixir -d -v /home/daisy/projects/erlang/elixir:/elixir -t elixir:latest
# you can use this to build elixir then copy relevant files to your local machine. Note that directories
# must be copied in exact same locations since paths are hard coded in erlang/elixir builds. So
# copy /opt/erlang from container to /opt/erlang on your local machine:
   ## docker cp elixir:/opt/elixir /opt
   ## docker cp elixir:/opt/erlang /opt
   ## Add /opt/erlang/bin and /opt/elixir/bin to your PATH
   ## If you get utf-8 warning while starting iex, copy lines with `apt install locales` and update-locale from above RUN
   ## statement to your local machine
