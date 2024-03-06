FROM ubuntu:22.04

ARG PREP_ARGS="--secure-boot --threads 4"

# Set timezone
RUN apt-get update && apt-get install -y tzdata
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create non-root user
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

# Install prerequisites
RUN sudo apt-get update
RUN sudo apt-get install -y gawk wget git diffstat unzip texinfo gcc pv graphviz \
                            build-essential chrpath socat cpio python3 python3-pip \
                            python3-pexpect xz-utils debianutils iputils-ping \
                            python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
                            python3-subunit mesa-common-dev zstd liblz4-tool \
                            file locales libacl1 make inkscape qemu nano \
                            texlive-latex-extra gpg curl python-is-python3 \
                            python3-gi gir1.2-ostree-1.0 gnutls-bin
RUN sudo apt-get remove oss4-dev
RUN pip3 install sphinx sphinx_rtd_theme pyyaml
RUN sudo locale-gen en_US.UTF-8

# Install latest version of google repo tool
RUN rm -rf ~/.repoconfig
RUN mkdir ~/.bin
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
RUN chmod a+rx ~/.bin/repo

# Configure git client
RUN git config --global user.name "John Doe"
RUN git config --global user.email "johndoe@example.com"
RUN git config --global http.postBuffer 1048576000
RUN git config --global https.postBuffer 1048576000

# Create yocto build environment
RUN sudo chmod -R 777 /opt
RUN mkdir /opt/yocto-state

RUN mkdir /opt/yocto
WORKDIR /opt/yocto
RUN ~/.bin/repo init -u git://git.toradex.com/toradex-manifest.git -b kirkstone-6.x.y -m tdxref/default.xml
RUN ~/.bin/repo sync -j1 --fail-fast

# Copy scripts and make them executable
RUN mkdir /opt/tools
COPY *.tgz /opt/tools
COPY *.sh /opt/tools
RUN sudo chmod a+rwx /opt/tools/*.sh
RUN sudo chmod a+rw /opt/tools/*.tgz
RUN sudo chown $USERNAME:$USERNAME /opt/tools/*.sh
RUN sudo chown $USERNAME:$USERNAME /opt/tools/*.tgz

# Copy previous build artifacts
RUN mkdir /opt/artifacts
COPY *.tar.gz /opt/artifacts
RUN sudo chmod a+rw /opt/artifacts/*.tar.gz
RUN sudo chown $USERNAME:$USERNAME /opt/artifacts/*.tar.gz

# Run environment setup script
RUN ../tools/prepare.sh $PREP_ARGS
