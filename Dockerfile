FROM ubuntu:16.04
MAINTAINER "Silas Tittes (mostly stolen)"

#stole it from https://dev-ops-notes.com/docker/howto-run-jupiter-keras-tensorflow-pandas-sklearn-and-matplotlib-docker-container/

RUN apt-get update && apt-get install -y wget ca-certificates \
    git curl vim python3-dev python3-pip \
    libfreetype6-dev libpng12-dev libhdf5-dev \
    pkg-config libgsl0-dev \
    bc \
    autoconf automake libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev libncurses5-dev

RUN pip3 install --upgrade pip

RUN pip3 install tensorflow \
&& pip3 install numpy pandas sklearn matplotlib seaborn jupyter pyyaml h5py \
&& pip3 install keras --no-deps \
&& pip3 install keras_applications==1.0.4 --no-deps \
&& pip3 install keras_preprocessing==1.0.2 --no-deps \
&& pip3 install h5py==2.8.0 \
&& pip3 install tables \
&& pip3 install joblib \
&& pip3 install msprime

#HTSLIB FROM GITHUB
RUN git clone https://github.com/samtools/htslib.git
WORKDIR /htslib/
RUN autoconf
RUN  make
RUN make install
WORKDIR /

#SAMTOOLS FROM GITHUB
RUN git clone https://github.com/samtools/samtools.git
WORKDIR /samtools
RUN autoheader \
&& autoconf -Wno-syntax \
&& ./configure \
&& make \
&& make install
WORKDIR /

#WGSIM FROM GITHUB
RUN git clone https://github.com/lh3/wgsim.git
WORKDIR /wgsim
RUN gcc -g -O2 -Wall -o wgsim wgsim.c -lz -lm
WORKDIR /

#BWA FROM GITHUB
RUN git clone https://github.com/lh3/bwa.git
WORKDIR /bwa
RUN make \
&& cp /bwa/bwa /usr/local/bin
WORKDIR /

#SEQ-GEN FROM GITHUB
RUN git clone https://github.com/rambaut/Seq-Gen.git
WORKDIR Seq-Gen/source/
RUN make \
&& cp /Seq-Gen/source/seq-gen /usr/local/bin
WORKDIR /

RUN ["mkdir", "notebooks"]
COPY jupyter_notebook_config.py /root/.jupyter/
COPY run_jupyter.sh /

# Jupyter and Tensorboard ports
EXPOSE 8888 6006

# Store notebooks in this mounted directory
VOLUME /notebooks

CMD ["/run_jupyter.sh", "bash"]
