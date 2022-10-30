FROM ubuntu:focal-20200720
# disable package prompt interaction
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update                 \
    && apt-get -y upgrade          \
    && apt-get install --no-install-recommends -y  \
        software-properties-common \
        dirmngr                    \
        vim                        \
        net-tools                  \
        dnsutils                   \
        iputils-ping               \
        netcat                     \
        sudo                       \
        wget                       \
        curl                       \
        tar                        \
        gzip                       \
        tzdata                     \
        tree                       \
        apt-utils                  \
        apt-transport-https        \
        ca-certificates            \
        gnupg-agent                \
        lsb-release
#  install Agent settings -- it's not a VSTS agent
#  install jq
RUN apt-get install -y jq
#  install yq
RUN add-apt-repository ppa:rmescandon/yq -y \
    &&  apt update                          \
    &&  apt install yq -y
# install zip unzip
RUN apt-get install zip unzip
# install git
RUN apt-get install -y git
# install sqlcmd
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    &&  curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
ENV ACCEPT_EULA=Y
RUN apt-get update \
    &&  apt-get install -y mssql-tools unixodbc-dev
# install mysql
RUN apt-get install -y mysql-client mysql-server
# mongodb client 
RUN apt install -y mongodb
# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl   \
    &&  chmod +x ./kubectl                                                                                                                                                      \
    &&  mv ./kubectl /usr/local/bin/kubectl
# install helm 2
RUN curl https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz > ./helm2.tar.gz    \
    &&  tar -xvf ./helm2.tar.gz                                                  \
    &&  mv ./linux-amd64/helm /usr/local/bin/helm2                               \
    &&  mv ./linux-amd64/tiller /usr/local/bin                                   \
    &&  rm ./helm2.tar.gz
# install helm 3
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3   \
    && chmod 700 get_helm.sh                                                                        \
    && ./get_helm.sh
# install kubelogin
RUN apt install wget unzip -y                                                                      \
    && wget https://github.com/Azure/kubelogin/releases/download/v0.0.20/kubelogin-linux-amd64.zip \
    && unzip kubelogin-linux-amd64.zip                                                             \
    && mv bin/linux_amd64/kubelogin /usr/bin                                                       \
    && rm -r kubelogin-linux-amd64.zip bin/linux_amd64
# install krew plugin
RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx \
    && ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx     \
    && ln -s /opt/kubectx/kubens /usr/local/bin/kubens
# install krew plugin autocomplete
RUN ln -sf /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens \
    && ln -sf /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
# linkerd cli
RUN curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh \
    && mv ~/.linkerd2/bin/linkerd-* /usr/local/bin/linkerd
RUN linkerd version --client
# cmctl cli
RUN curl -sSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.8.2/cmctl-linux-amd64.tar.gz \
    && tar xzf cmctl.tar.gz                                                                                                  \
    && mv cmctl /usr/local/bin
# step cli
RUN wget https://dl.step.sm/gh-release/cli/docs-cli-install/v0.21.0/step-cli_0.21.0_amd64.deb \
    && dpkg -i step-cli_0.21.0_amd64.deb
# install terraform cli
ARG TERRAFORM_VERSION="1.0.11"
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN echo ${TERRAFORM_URL}                                   \
    &&  curl -fSL ${TERRAFORM_URL} -o /bin/terraform.zip    \
    &&  unzip /bin/terraform.zip -d /usr/local/bin          \
    &&  rm -f /bin/terraform.zip
# install ansible
RUN apt install -y python3-pip \
    && python3 -m pip install --user ansible
# install az CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
# install az extensions
RUN az extension add --yes --name aks-preview               \
    && az extension add --yes --name application-insights   \
    && az extension add --yes --name azure-devops           \
    && az extension add --yes --name ssh                    \
    && az extension add --yes --name storage-preview 
# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip                                                             \
    && ./aws/install
# install powershell
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb  \
    &&  dpkg -i packages-microsoft-prod.deb                                                 \
    &&  apt-get update                                                                      \
    &&  add-apt-repository universe -y                                                      \
    &&  apt-get install -y powershell
# install powershell module Az command: 
# install-Module -Name Az -AllowClobber -Scope CurrentUser
# install AzCopy
RUN wget https://aka.ms/downloadazcopy-v10-linux    \
    &&  tar -xvf downloadazcopy-v10-linux           \
    &&  cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
# install az devops
# az devops configure --defaults organization-https://dev.azure.com/contosoWebApp project=PaymentModule
# install az pipelines
# install node
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
#     &&  apt-get install -y nodejs
RUN apt-get install -y nodejs
# install npm
RUN apt-get install -y npm
# install tsc typescript
# install docker
RUN apt-get update                                                                          \
    &&  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -        \
    &&  add-apt-repository                                                                  \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu                          \
        $(lsb_release -cs)                                                                  \
        stable" -y                                                                          \
    &&  apt-get update                                                                      \
    &&  apt-get install -y docker-ce
# install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  \
    &&  chmod +x /usr/local/bin/docker-compose                                                                                                    \
    &&  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# install supervisor (init scheme)
RUN apt-get install -y supervisor 
COPY ./supervisord.conf /etc/supervisord.conf
ARG USER_NAME=admin
ARG USER_PASSWORD=Password
RUN useradd -m -d /home/$USER_NAME -s /bin/bash $USER_NAME
RUN echo "$USER_NAME:$USER_PASSWORD" | chpasswd
RUN usermod -aG docker $USER_NAME && usermod -aG sudo $USER_NAME
WORKDIR /home/$USER_NAME
USER $USER_NAME
# isntall krew
RUN ( \
    set -x; cd "$(mktemp -d)" \
    && OS="$(uname | tr '[:upper:]' '[:lower:]')" \
    && ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" \
    && KREW="krew-${OS}_${ARCH}" \
    && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" \
    && tar zxvf "${KREW}.tar.gz" \
    && ./"${KREW}" install krew \
    )
# ports and entrypoint configuration
EXPOSE 3306
CMD ["/usr/bin/supervisord"]