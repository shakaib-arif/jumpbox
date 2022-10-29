FROM ubuntu:20.04
# disable package prompt interaction
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update      && \
    apt-get -y upgrade  && \
    apt-get install -y     \
        software-properties-common \
        dirmngr                    \
        vim                        \
        net-tools                  \
        sudo                       \
        wget                       \
        curl                       \
        apt-utils                  \
        apt-transport-https        \
        ca-certificates            \
        gnupg-agent                
#  install Agent settings -- it's not a VSTS agent
#  install jq
RUN apt-get install -y jq
#  install yq
RUN add-apt-repository ppa:rmescandon/yq -y && \
    apt update                              && \
    apt install yq -y
# install zip unzip
RUN apt-get install zip unzip
# install sqlcmd
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
ENV ACCEPT_EULA=Y
RUN apt-get update && \
    apt-get install -y mssql-tools unixodbc-dev
# install mysql
RUN apt-get install -y mysql-client mysql-server
# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl   && \
    chmod +x ./kubectl                                                                                                                                                          && \
    sudo mv ./kubectl /usr/local/bin/kubectl
# install helm
RUN curl https://get.helm.sh/helm-v2.14.0-linux-amd64.tar.gz > ./helm.tar.gz    && \
    tar -xvf ./helm.tar.gz                                                      && \ 
    mv ./linux-amd64/helm /usr/local/bin                                        && \
    mv ./linux-amd64/tiller /usr/local/bin
# RUN helm version
# install az
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# install powershell
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb  && \
    dpkg -i packages-microsoft-prod.deb                                                     && \
    apt-get update                                                                          && \
    add-apt-repository universe -y                                                          && \
    apt-get install -y powershell
# install powershell module Az command: 
# install-Module -Name Az -AllowClobber -Scope CurrentUser
# install AzCopy
RUN wget https://aka.ms/downloadazcopy-v10-linux    && \
    tar -xvf downloadazcopy-v10-linux               && \
    cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
# install az devops
# az devops configure --defaults organization-https://dev.azure.com/contosoWebApp project=PaymentModule
# install az pipelines
# mongodb client 
RUN apt install -y mongodb
# install git
RUN apt-get install -y git
# install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt-get install -y nodejs
# install tsc typescript
# install docker
RUN apt-get update                                                                          && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -            && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" -y                                                                          && \
    apt-get update                                                                          && \
    apt-get install -y docker-ce
# install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  && \
    chmod +x /usr/local/bin/docker-compose                                                                                                        && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# install supervisor (init scheme)
RUN apt-get install -y supervisor 
COPY ./supervisord.conf /etc/supervisord.conf
ARG USER_NAME=admin
RUN useradd -m -d /home/$USER_NAME -s /bin/bash $USER_NAME
RUN echo "$USER_NAME:Password" | chpasswd
RUN usermod -aG docker $USER_NAME && usermod -aG sudo $USER_NAME
#USER $USER_NAME
WORKDIR /home/$USER_NAME
# ports and entrypoint configuration
EXPOSE 3306
CMD ["/usr/bin/supervisord"]