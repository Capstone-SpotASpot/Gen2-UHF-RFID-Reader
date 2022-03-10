# syntax=docker/dockerfile:1
FROM ubuntu:16.04
ADD ./log4cpp-1.1.3.tar.gz /root
ADD https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz /root/

ADD ./.nanorc /root
ADD ./.bashrc /root
WORKDIR /root
RUN debian_frontend=noninteractive
RUN apt update -y && apt upgrade -y
RUN apt install -y nano git
RUN git clone --recursive https://github.com/nkargas/Gen2-UHF-RFID-Reader.git
RUN git clone --recursive --branch v3.14.0.0 https://github.com/EttusResearch/uhd
# NOTE: cmake for Gen2-UHF-RFID-Reader requires gnuradio-v3.7.2
RUN git clone --recursive --branch maint-3.7 https://github.com/gnuradio/gnuradio.git
# needs to be thrift v10.0
RUN git clone https://github.com/apache/thrift.git --branch 0.10.0 --depth 1

# install instructions from https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux
RUN apt install -y \
    git swig doxygen build-essential libboost-all-dev \
    libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev \
    libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc \
    libcppunit-1.13-0v5 libcppunit-dev libcppunit-doc ncurses-bin \
    cpufrequtils python-numpy python-numpy-doc python-numpy-dbg \
    python-scipy python-docutils qt4-bin-dbg qt4-default qt4-doc \
    libqt4-dev libqt4-dev-bin python-qt4 python-qt4-dbg python-qt4-dev \
    python-qt4-doc python-qt4-doc libqwt6abi1 libfftw3-bin libfftw3-dev \
    libfftw3-doc ncurses-bin libncurses5 libncurses5-dev libncurses5-dbg \
    libfontconfig1-dev libxrender-dev libpulse-dev swig g++ automake autoconf \
    libtool python-dev libfftw3-dev libcppunit-dev libboost-all-dev libusb-dev \
    libusb-1.0-0-dev fort77 libsdl1.2-dev python-wxgtk3.0 git-core libqt4-dev \
    python-numpy ccache python-opengl libgsl-dev python-cheetah python-mako \
    python-lxml doxygen qt4-default qt4-dev-tools libusb-1.0-0-dev libqwt5-qt4-dev \
    libqwtplot3d-qt4-dev pyqt4-dev-tools python-qwt5-qt4 git-core wget \
    libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev \
    libasound2-dev python-gtk2 libzmq-dev libzmq1 python-requests python-sphinx \
    libcomedi-dev python-zmq python-setuptools libssl-dev bison flex

# make latest cmake (needed for gnuradio)
WORKDIR /root/
RUN tar -xzvf cmake-3.22.1.tar.gz
WORKDIR /root/cmake-3.22.1
RUN ./bootstrap && make -j$(($(nproc)-1)) && make install

# make log4cpp
WORKDIR /root/log4cpp
RUN ./configure && make -j$(($(nproc)-1)) && make -j$(($(nproc)-1)) install

# build uhd
RUN mkdir -p /root/uhd/host/build
WORKDIR /root/uhd/host/build
RUN cmake  ../
RUN make -j$(($(nproc)-1))
RUN make -j$(($(nproc)-1)) install
RUN ldconfig
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
RUN uhd_images_downloader

# build thrift (for gnuradio)
RUN cd /root/thrift \
    && ./bootstrap.sh \
    && ./configure \
        --with-c_glib \
        --with-cpp \
        --with-libevent \
        --with-python \
        --without-csharp \
        --without-d \
        --without-erlang \
        --without-go \
        --without-haskell \
        --without-java \
        --without-lua \
        --without-nodejs \
        --without-perl \
        --without-php \
        --without-ruby \
        --without-zlib \
        --without-qt4 \
        --without-qt5 \
        --disable-tests \
        --disable-tutorial \
        --prefix=/usr \
    && make -j$(($(nproc)-1)) && make -j$(($(nproc)-1)) install \
    && mv /usr/lib/python2.7/site-packages/thrift /usr/lib/python2.7/dist-packages
RUN cd /root/thrift \
    && PYTHON=/usr/bin/python3 ./configure \
        --with-c_glib \
        --with-cpp \
        --with-libevent \
        --with-python \
        --without-csharp \
        --without-d \
        --without-erlang \
        --without-go \
        --without-haskell \
        --without-java \
        --without-lua \
        --without-nodejs \
        --without-perl \
        --without-php \
        --without-ruby \
        --without-zlib \
        --without-qt4 \
        --without-qt5 \
        --disable-tests \
        --disable-tutorial \
        --prefix=/usr \
    && make -j$(($(nproc)-1)) && make -j$(($(nproc)-1)) install \
    && mv /usr/lib/python3.6/site-packages/thrift /usr/lib/python3/dist-packages

# build volk
RUN mkdir -p /root/gnuradio/volk/build
WORKDIR /root/gnuradio/volk/build
RUN cmake ../
RUN make -j$(($(nproc)-1))
RUN make install
RUN ldconfig

# build gnuradio
WORKDIR /root/gnuradio
RUN git submodule update --init --recursive
RUN mkdir -p /root/gnuradio/build
WORKDIR /root/gnuradio/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ../
RUN make -j$(($(nproc)-1))
RUN make install
RUN ldconfig

# build Gen2-UHF-RFID-Reader
RUN mkdir -p /root/Gen2-UHF-RFID-Reader/gr-rfid/build
WORKDIR /root/Gen2-UHF-RFID-Reader/gr-rfid/build
RUN cmake ../
RUN make -j$(($(nproc)-1)) && make -j$(($(nproc)-1)) install
RUN ldconfig
