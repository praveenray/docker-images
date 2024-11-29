FROM ubuntu AS build
ENV DEBIAN_INTERACTIVE=non-interactive
RUN apt-get update -y
RUN apt-get install curl -y
WORKDIR /opt
RUN apt install build-essential zlib1g-dev libreadline6-dev libicu-dev pkg-config -y

WORKDIR /opt
RUN curl -o postgres.tar.gz2 "https://ftp.postgresql.org/pub/source/v16.3/postgresql-16.3.tar.bz2"

RUN tar jxf postgres.tar.gz2 && \
    cd postgresql-16.3 && \
    ./configure --prefix=/opt/postgres && \
    make --jobs=$(nproc) && \
    make install

SHELL ["/bin/bash", "-c"]

RUN groupadd -r postgres && \
    useradd -r -m -g postgres postgres && \
    echo "postgres:postgres" | chpasswd && \
    echo 'export PATH=$PATH:/opt/postgres/bin' > /etc/profile && \
    mkdir -p /opt/postgres-data && \
    chown -R postgres:postgres /opt/postgres-data && \
    source /etc/profile

COPY copy-pg-shared-libs.pl /opt

RUN chmod +x copy-pg-shared-libs.pl && \
    ./copy-pg-shared-libs.pl

ENTRYPOINT ["tail", "-f", "/dev/null"]


FROM ubuntu
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y && \
    apt-get install language-pack-en -y && \
    sed -i "s/^# en_US ISO-8859-1/en_US ISO-8859-1/" /etc/locale.gen && \
    update-locale LANG=en_US.UTF-8

RUN groupadd -r postgres && \
    useradd -r -m -g postgres postgres && \
    echo "postgres:postgres" | chpasswd && \
    echo 'export PATH=$PATH:/opt/postgres/bin' >> /etc/profile && \
    echo 'export LD_LIBRARY_PATH=/opt/postgres-shared-libs' >> /etc/profile && \
    mkdir -p /opt/postgres-data && \
    chown -R postgres:postgres /opt/postgres-data

COPY --from=build /opt /opt
USER postgres

RUN source /etc/profile && \
    initdb -D /opt/postgres-data -U postgres && \
    sed -i "s/#listen_addresses =.*/listen_addresses ='*'/" /opt/postgres-data/postgresql.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /opt/postgres-data/pg_hba.conf

RUN source /etc/profile && \
    echo "create role db_admin login password 'db_admin'" >> /opt/postgres-data/user.sql && \
    echo "alter role db_admin superuser" >> /opt/postgres-data/super.sql && \
    pg_ctl -D /opt/postgres-data -l /opt/postgres-data/logfile start && \
    psql -f /opt/postgres-data/user.sql && \
    psql -f /opt/postgres-data/super.sql && \
    pg_ctl -D /opt/postgres-data -l /opt/postgres-data/logfile stop && \
    rm -f /opt/postgres-data/user.sql && \
    rm -f /opt/postgres-data/super.sql

# Fix template1 to have correct locale settings. Is there a better way?
# Copied from https://stackoverflow.com/questions/18870775/how-to-change-the-template-database-collection-coding
RUN source /etc/profile && \
    echo "ALTER database template1 is_template=false;" >> /opt/postgres-data/template.sql && \
    echo "DROP database template1;" >> /opt/postgres-data/template.sql && \
    echo "CREATE DATABASE template1 WITH OWNER=db_admin" >> /opt/postgres-data/template.sql && \
    echo "ENCODING = 'UTF8' TABLESPACE = pg_default" >> /opt/postgres-data/template.sql && \
    echo "LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8'" >> /opt/postgres-data/template.sql && \
    echo "CONNECTION LIMIT = -1" >> /opt/postgres-data/template.sql && \
    echo "TEMPLATE template0;" >> /opt/postgres-data/template.sql && \
    echo "ALTER database template1 is_template=true;"  >> /opt/postgres-data/template.sql && \
    pg_ctl -D /opt/postgres-data -l /opt/postgres-data/logfile start && \
    psql -f /opt/postgres-data/template.sql && \
    createdb hello && \
    pg_ctl -D /opt/postgres-data -l /opt/postgres-data/logfile stop && \
    rm -f /opt/postgres-data/template.sql

RUN echo 'source /etc/profile &&  postgres -D /opt/postgres-data > /opt/postgres-data/logfile 2>&1' > /home/postgres/pg.sh && \
    chmod +x /home/postgres/pg.sh

USER root
ENTRYPOINT ["su", "postgres", "-s", "/bin/bash", "-c", "/home/postgres/pg.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]


# docker build -t postgres:16 -f postgres.dockerfile .
# docker run -p 5432:5432 --rm -d --name pg -t postgres:16
# connect to 'hello' database using:
#   jdbcpostgresql://<IP>:5432/hello
#   username db_admin
#   password db_admin
