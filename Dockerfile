FROM ubuntu
MAINTAINER Fabian Rost (fabrost@pks.mpg.de)

#########
### Aptitude packages
#########
RUN apt-get update --fix-missing
RUN	apt install -y build-essential locales supervisor wget vim \
                   openssl openssh-server bzip2 ca-certificates \
                   ibglib2.0-0 libxext6 libsm6 libxrender1 \
                   git mercurial subversion

#########
### Squash locale warnings
#########
RUN rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

#########
### Working dir
#########
RUN	mkdir build
WORKDIR /build

#########
## create the User
#########
RUN groupadd -g 2000 fabrost && useradd -m -u 2000 -g 2000 fabrost
RUN chsh -s /bin/bash fabrost
RUN echo "alias ll='ls -la -G'" >> /home/fabrost/.profile
RUN	usermod -G fabrost,www-data fabrost

#########
## Miniconda
#########
WORKDIR /home/fabrost
USER fabrost
RUN wget --quiet \
    https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O ~/miniconda.sh
RUN /bin/bash ~/miniconda.sh -b -p /home/fabrost/miniconda
RUN rm ~/miniconda.sh
RUN echo "export PATH="/home/fabrost/miniconda/bin:$PATH"" >> ~/.bashrc && \
    echo "source activate spols" >> ~/.bashrc
COPY environment.yml /home/fabrost/
RUN ~/miniconda/bin/conda env create
RUN rm environment.yml


#########
### Clean up
#########
WORKDIR /
RUN rm -rf /build

#########
### Supervisor
#########
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#########
### Volumes
#########
RUN mkdir /home/fabrost/share
VOLUME /home/fabrost/share

## Install an SSH of your choice.
COPY id_rsa.pub /tmp/id_rsa.pub
RUN mkdir /home/fabrost/.ssh
RUN cat /tmp/id_rsa.pub >> /home/fabrost/.ssh/authorized_keys
RUN rm -f /tmp/id_rsa.pub

#########
### Ports and CMD
#########
EXPOSE 22
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
