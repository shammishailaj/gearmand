FROM ubuntu:16.04
RUN echo -e "LC_ALL=\"en_US.UTF-8\"\nLANG=\"en_US.UTF-8\"\nLANGUAGE=\"en_US.UTF-8\"\nLC_TYPE=\"UTF-8\"\n" | tee -a /etc/environment
RUN export LC_ALL="en_US.UTF-8"
RUN export LANG="en_US.UTF-8"
RUN export LANGUAGE="en_US.UTF-8"
RUN export LC_TYPE="UTF-8"
RUN apt-get update && apt-get -y install apt-utils && apt-get -y upgrade
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "mysql-server mysql-server/root_password password 123456" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password 123456" | debconf-set-selections
RUN apt-get -y install mysql-server
RUN apt-get -y install wget g++ make libevent-dev uuid-dev libmysql++-dev python-sphinx libtool automake libsqlite3-dev libssl-dev libmemcached-dev git gperf libboost-program-options-dev
RUN wget https://github.com/gearman/gearmand/releases/download/1.1.16/gearmand-1.1.16.tar.gz
RUN tar -xvzf gearmand-1.1.16.tar.gz
RUN cd gearmand-1.1.16 && ./configure --enable-ssl && make && make install
RUN echo -e "\n[mysqld]\nbind-address = 0.0.0.0\nsql_mode = NO_ENGINE_SUBSTITUTION\n" | tee -a /etc/mysql/conf.d/mysql.cnf
RUN service mysql restart
RUN mysql -u root -p123456 -e"CREATE DATABASE gearman;"
RUN touch /var/log/gearmand.log
EXPOSE 4730
EXPOSE 8080
CMD gearmand --listen 0.0.0.0 --port 4730 --queue-type mysql --mysql-host localhost --mysql-port 3306 --mysql-user root --mysql-password 123456 --mysql-db gearman --log-file /var/log/gearmand.log --verbose DEBUG --http-port=8080 --protocol=http
