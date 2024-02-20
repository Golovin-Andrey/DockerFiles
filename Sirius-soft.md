# From apt-get:

Compilers:

    sudo apt install cmake git gfortran gcc g++ gcc-9 g++-9 openmpi-common

Network:

    sudo apt install openssh-server

Virtulization:

  - Docker

        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources:
        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  - Singularity

        wget https://github.com/sylabs/singularity/releases/download/v4.0.2/singularity-ce_4.0.2-focal_amd64.deb
        sudo dpkg -i singularity-ce_4.0.2-focal_amd64.deb
        sudo apt install -f

Slurm 

    sudo apt update -y
    sudo apt install slurm-client 

Ansible

    sudo apt-add-repository ppa:ansible/ansible
    sudo apt update
    sudo apt install ansible

    SSH keys will be needed
    
Multimedia:

    sudo apt install netpbm mencoder

Shall we install nvidia stuff from their repos? Otherwise:

    sudo apt install nvidia-cuda-dev nvidia-cuda-toolkit

# Other:

## GROMACS:

    VERSION=2023.3
    wget https://ftp.gromacs.org/gromacs/gromacs-${VERSION}.tar.gz
    tar -xvf gromacs-${VERSION}.tar.gz
    cd gromacs-${VERSION}
    mkdir build
    cd build
    cmake .. -DGMX_GPU=CUDA -DCMAKE_C_COMPILER=gcc-9 -DCMAKE_CXX_COMPILER=g++-9
    make -j12
    sudo make install

Note that the default installation folder is `/usr/local/gromacs/bin/`

## VMD ?:

    # Download and unpack the code - registration needed
    ./configure
    cd src
    sudo make install
    
# PyMol
    
    sudo  apt install pymol
    

# Some other considerations

- Will this image be compatible with other computers (e.g. without NVidia GPUs, with different SIMD architecture)?
  - we will talk with sysadm about computer diversity
