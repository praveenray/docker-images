FROM ubuntu
ENV DEBIAN_INTERACTIVE=non-interactive
RUN apt-get update -y
RUN apt-get install xterm curl git -y
WORKDIR /opt
RUN curl -o emacs-29.tar.gz https://git.savannah.gnu.org/cgit/emacs.git/snapshot/emacs-emacs-29.4.tar.gz && \
    tar zxf emacs-29.tar.gz && \
    rm -f emacs-29.tar.gz && \
    mv emacs-emacs-29.4 emacs-src
RUN apt install build-essential libgtk-3-dev libgnutls28-dev libtiff5-dev libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo libjansson4 libjansson-dev -y

RUN apt install libgccjit0 libgccjit-13-dev libgccjit-10-dev gcc-10 g++-10 libtree-sitter-dev autoconf libmagickcore-dev libmagick++-dev -y

RUN cd emacs-src && \
    export CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10 && \
   ./autogen.sh
RUN cd emacs-src && \
   ./configure --prefix=/opt/emacs  --with-native-compilation   --with-json   --with-tree-sitter   --with-imagemagick && \
   make --jobs=$(nproc) && \
   make install && \
   rm -rf /opt/emacs-src

COPY copy-emacs-shared-libs.pl /opt/emacs
RUN chmod +x /opt/emacs/copy-emacs-shared-libs.pl && \
    /opt/emacs/copy-emacs-shared-libs.pl

RUN echo "export PATH=\$PATH:/opt/emacs/bin" >> ~/.bashrc

# Adjust the UID/GID to whatever user you want host files to be mounted as.
# You can simply comment it out if you don't need to mount host files
USER 1000:1000
RUN  echo "export PATH=\$PATH:/opt/emacs/bin:/opt/doomemacs/bin" >> ~/.bashrc

# doom emacs. Comment this region if you want only vanilla emacs
# you probably need to run M-x: nerd-icons-install-fonts inside doom for proper icons display
RUN export PATH=$PATH:/opt/emacs/bin && \
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/doomemacs && \
    cd ~/doomemacs/bin && \
    ./doom install --force && \
    echo "export PATH=\$PATH:$HOME/doomemacs/bin" >> ~/.bashrc && \
    ./doom sync
# end doom emacs

ENTRYPOINT ["tail", "-f", "/dev/null"]

# docker build -t emacs29:ubuntu -f emacs29-ubuntu.dockerfile .
# docker run --rm -d --name emacs -eDISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -t emacs29:ubuntu
# You can mount your host directory if you need:
   # docker run --rm -d --name emacs -eDISPLAY=$DISPLAY  -v /path/to/host/dir:/path/inside/container  -v /tmp/.X11-unix/:/tmp/.X11-unix/ -t emacs29:ubuntu
   # this assumes your host user id (i.e. 1000) exists in container
# docker exec -it emacs bash OR docker exec -u 0 -it emacs bash (to login as root)
# Then simply do `doom run`

# Once this container is running, you can either run emacs from within it or copy /opt/emacs folder to your host and run emacs from there.
# If you do the latter, make sure to do `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/emacs/shared-libs` first.
# Copying from container to host will only work if both have same glibc version.
#   In order to find glic version, run this command on host and guest: `ldd --version`
