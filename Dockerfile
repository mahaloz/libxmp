FROM ubuntu:18.04

USER root 
RUN apt-get update && apt-get install -y sudo sshfs bsdutils python3-dev python-pip \
    libpq-dev pkg-config zlib1g-dev libtool libtool-bin wget automake autoconf coreutils bison libacl1-dev \
    llvm clang \
    build-essential git \
    libffi-dev cmake libreadline-dev libtool netcat net-tools 


# ----- mahaloz stuff ----- #
USER root
RUN apt-get update && apt-get install -y \
    tmux \
    xclip \
    vim

# ----- target ----- #
# get source
RUN git clone https://github.com/libxmp/libxmp.git && cd libxmp \
    export CC=clang && \
    autoconf; ./configure --enable-static && \
    make -j3 && \
    make check && \
    make install && \
    export PATH="/usr/local/lib/:$PATH"

# compile
RUN cd /libxmp/test-dev && \
    clang -fsanitize=fuzzer,address,undefined libxmp_fuzz.c -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_LIBM=1 -DHAVE_PIPE=1 -DHAVE_POPEN=1 -DHAVE_MKSTEMP=1 -DHAVE_FNMATCH=1 -I../include -I../src -L../lib -lxmp -lm

# fix paths and fuzz target
RUN ln -s /usr/local/lib/libxmp.so /lib/x86_64-linux-gnu/libxmp.so.4  && \
    cp /libxmp/test-dev/a.out /fuzzme && \
    cd / 


