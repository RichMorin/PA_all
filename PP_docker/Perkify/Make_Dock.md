# Make_Dock

These notes describe the setup of the Perkian Docker environment on Fido.

### Installation

According to `https://docs.docker.com/install/linux/docker-ce/ubuntu/`,
Docker Engine should be installed as follows:

    sudo -s

    apt-get update

    apt-get remove docker docker-engine docker.io containerd runc

    apt-get install apt-transport-https ca-certificates \
      curl gnupg-agent software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    apt-key fingerprint 0EBFCD88
    # pub   rsa4096 2017-02-22 [SCEA]
    #       9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
    # uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
    # sub   rsa4096 2017-02-22 [S]

    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) stable"

    apt-get update

    apt-get install docker-ce docker-ce-cli containerd.io

    docker run hello-world

    docker run -it ubuntu bash
    
    
    
    
    
    