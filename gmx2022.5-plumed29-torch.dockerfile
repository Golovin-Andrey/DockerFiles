FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

#%files
#    /home/domain/data/silwer/gpcr_martini2/scripts/gmx /usr/local/bin/gmx

# Install python3
# SPlonItYSiAn
RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    python3 \
    sudo \
    ssh \
        build-essential \
        ca-certificates \
        libblas-dev \
        liblapack-dev \
        perl \
        wget \
        liblapack64-dev \
        libblas64-dev \
        git xxd \
        gfortran \
        unzip tmux vim \ 
        libopenmpi-dev \
        python3-pip
# Install latest CMAKE
#
ARG user=golovin
RUN useradd --create-home -s /bin/bash $user && echo $user:simulation | chpasswd  && adduser $user sudo
ARG user=generic
RUN useradd --create-home -s /bin/bash $user && echo $user:mdcruser | chpasswd
#RUN useradd -m -p $(perl -e 'print crypt($ARGV[0], "password")' 'SPlonItYSiAn') generic
#RUN usermod -aG sudo generic 
RUN pip3 install cmake
#CMD /bin/bash
# Install dependencies for gromacs
#
#
ENV TMPDIR=/tmp
WORKDIR  ${TMPDIR}
RUN cd /opt ;  wget -q -nc --no-check-certificate -P /opt https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.2.0%2Bcpu.zip ; ls -lh
RUN cd /opt ;  unzip  "libtorch-cxx11-abi-shared-with-deps-2.2.0+cpu.zip" ; rm -f "libtorch-cxx11-abi-shared-with-deps-2.2.0+cpu.zip"
RUN echo "export CPATH=/opt/libtorch/include/torch/csrc/api/include/:/opt/libtorch/include/:/opt/libtorch/include/torch:$CPATH ; \ 
export INCLUDE=/opt/libtorch/include/torch/csrc/api/include/:/opt/libtorch/include/:/opt/libtorch/include/torch:$INCLUDE ;\
export LIBRARY_PATH=/opt/libtorch/lib:$LIBRARY_PATH ; export LD_LIBRARY_PATH=/opt/libtorch/lib:$LD_LIBRARY_PATH "  > /opt/libtorch/sourceme.sh

ENV  PLUMED_VERSION=2.9.0
RUN  mkdir -p ${TMPDIR} && wget -q -nc --no-check-certificate -P ${TMPDIR} https://github.com/plumed/plumed2/releases/download/v${PLUMED_VERSION}/plumed-src-${PLUMED_VERSION}.tgz ;\
    mkdir -p ${TMPDIR} && tar -x -f ${TMPDIR}/plumed-src-${PLUMED_VERSION}.tgz -C ${TMPDIR} -z ;\
    cd ${TMPDIR}/plumed-${PLUMED_VERSION} ;\
    . /opt/libtorch/sourceme.sh ;\
    env ;\
    sed -i.back 's/-std=c++14/-std=c++17/' ./configure ;\
    ./configure --prefix=/opt/plumed --enable-libtorch --enable-modules=all ;\
    make -j4 ;\
    make install 


ENV GMX_VERSION=2022.5
RUN wget -q -nc --no-check-certificate -P ${TMPDIR} ftp://ftp.gromacs.org/pub/gromacs/gromacs-${GMX_VERSION}.tar.gz
RUN cd ${TMPDIR}/ ; ls ;tar xf  gromacs-${GMX_VERSION}.tar.gz ; cd gromacs-${GMX_VERSION}; \ 
    LD_LIBRARY_PATH=/opt/plumed/lib:/opt/libtorch/lib /opt/plumed/bin/plumed patch -p -e gromacs-2022.5
RUN mkdir -p ${TMPDIR}/gromacs-${GMX_VERSION}/build ; cd  ${TMPDIR}/gromacs-${GMX_VERSION}/build ;\
    cmake ..  -D GMX_OPENMP=ON -D GMX_MPI=ON -D GMX_GPU=CUDA -D GMX_DOUBLE=OFF -D GMX_BUILD_OWN_FFTW=ON -D CMAKE_INSTALL_PREFIX=/opt/gromacs ; \
    LD_LIBRARY_PATH=/opt/plumed/lib:/opt/libtorch/lib make -j4 ; LD_LIBRARY_PATH=/opt/plumed/lib:/opt/libtorch/lib  make install 

