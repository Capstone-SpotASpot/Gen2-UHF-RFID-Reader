#!/usr/bin/env bash
# for ubuntu 16 environments (builds in docker)

START_DIR="$PWD"

# install instructions from
# https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux
# https://github.com/gnuradio/gnuradio-docker/blob/master/ci/ci-ubuntu-20.04-3.9/Dockerfile
sudo apt update -y
sudo apt install -qy --no-install-recommends \
    git \
    swig \
    doxygen \
    build-essential \
    libboost-all-dev \
    libtool \
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    libudev-dev \
    libncurses5-dev \
    libfftw3-bin \
    libfftw3-dev \
    libfftw3-doc \
    libcppunit-1.13-0v5 \
    libcppunit-dev \
    libcppunit-doc \
    ncurses-bin \
    cpufrequtils \
    python-numpy \
    python-numpy-doc \
    python-numpy-dbg \
    python-scipy \
    python-docutils \
    qt4-bin-dbg \
    qt4-default \
    qt4-doc \
    libqt4-dev \
    libqt4-dev-bin \
    python-qt4 \
    python-qt4-dbg \
    python-qt4-dev \
    python-qt4-doc \
    python-qt4-doc \
    libqwt6abi1 \
    libfftw3-bin \
    libfftw3-dev \
    libfftw3-doc \
    ncurses-bin \
    libncurses5 \
    libncurses5-dev \
    libncurses5-dbg \
    libfontconfig1-dev \
    libxrender-dev \
    libpulse-dev \
    swig \
    g++ \
    automake \
    autoconf \
    libtool \
    python-dev \
    libfftw3-dev \
    libcppunit-dev \
    libboost-all-dev \
    libusb-dev \
    libusb-1.0-0-dev \
    fort77 \
    libsdl1.2-dev \
    python-wxgtk3.0 \
    git-core \
    libqt4-dev \
    ccache \
    python-opengl \
    libgsl-dev \
    python-cheetah \
    python-mako \
    python-lxml \
    doxygen \
    qt4-default \
    qt4-dev-tools \
    libusb-1.0-0-dev \
    libqwt5-qt4-dev \
    libqwtplot3d-qt4-dev \
    pyqt4-dev-tools \
    python-qwt5-qt4 \
    git-core \
    wget \
    libxi-dev \
    gtk2-engines-pixbuf \
    r-base-dev \
    python-tk \
    liborc-0.4-0 \
    liborc-0.4-dev \
    libasound2-dev \
    python-gtk2 \
    libzmq-dev \
    libzmq1 \
    python-requests \
    python-sphinx \
    libcomedi-dev \
    python-zmq \
    python-setuptools \
    libssl-dev \
    bison \
    flex \
    python-cheetah \
    python-click \
    python-click-plugins \
    python-dev \
    python-gi \
    python-gi-cairo \
    python-gtk2 \
    python-lxml \
    python-mako \
    python-numpy \
    python-opengl \
    python-qt4 \
    python-pyqt5 \
    python-wxgtk3.0 \
    python-yaml \
    python-zmq \
    build-essential \
    ccache \
    cmake \
    libad9361-dev \
    libboost-date-time-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libcomedi-dev \
    libcppunit-dev \
    libfftw3-dev \
    libgmp-dev \
    libgsl0-dev \
    libiio-dev \
    liblog4cpp5-dev \
    libqt4-dev \
    libqwt-dev \
    libqwt5-qt4 \
    libqwt-qt5-dev \
    qtbase5-dev \
    libsdl1.2-dev \
    libuhd-dev \
    libusb-1.0-0-dev \
    libzmq3-dev \
    libgsm1-dev \
    libcodec2-dev \
    portaudio19-dev \
    pyqt4-dev-tools \
    pyqt5-dev-tools \
    python-cheetah \
    python-sphinx \
    doxygen \
    doxygen-latex \
    swig

# make latest cmake (needed for gnuradio)
cd "${START_DIR}"
if [[ -d cmake-3.22.1 ]]; then
    echo "Already extracted cmake-3.22.1 here"
else # already extracted cmake dir
    wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz
    tar -xzvf cmake-3.22.1.tar.gz
fi
cd "${START_DIR}/cmake-3.22.1"
./bootstrap && make -j$(($(nproc)-1)) && sudo make install

# make log4cpp
# download log4cpp from here: http://log4cpp.sourceforge.net/
cd "${START_DIR}"
if [[ -d log4cpp ]]; then
    echo "log4cpp already extracted here"
else # log4cpp folder dne
    # log4cpp tar exists, but not extracted
    if [[ -f "log4cpp-1.1.3.tar.gz" ]]; then
        tar -xzvf log4cpp-1.1.3.tar.gz ./
    else # there is no log4cpp tar file
        echo "Please download log4cpp-1.1.3.tar.gz from http://log4cpp.sourceforge.net/ and save it here"
        exit
    fi
fi

# --build=arm-linux-eabi --host=arm-linux-eabi for nvidia tx2
# disable static or else get PIC issue with gnuradio
cd "${START_DIR}/log4cpp" \
    && export CFLAGS="$CFLAGS -fPIC" \
    && export CXXFLAGS="$CXXFLAGS -fPIC" \
    && ./configure --disable-static \
        --build=arm-linux-eabi \
        --host=arm-linux-eabi \
        --enable-shared \
    && make -j$(($(nproc)-1)) \
    && sudo make -j$(($(nproc)-1)) install \
    && sudo ldconfig


# build uhd
cd "${START_DIR}"
git clone --recursive --branch v3.14.0.0 https://github.com/EttusResearch/uhd
mkdir -p "${START_DIR}/uhd/host/build"
cd "${START_DIR}/uhd/host/build"
cmake -DCMAKE_BUILD_TYPE=Release ../
make -j$(($(nproc)-1))
sudo make -j$(($(nproc)-1)) install
sudo ldconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
sudo uhd_images_downloader

# build thrift (for gnuradio)
# needs to be thrift v10.0
cd "${START_DIR}"
git clone https://github.com/apache/thrift.git --branch 0.10.0 --depth 1
cd "${START_DIR}/thrift" \
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
    && make -j$(($(nproc)-1)) \
    && sudo make -j$(($(nproc)-1)) install \
    && sudo cp -r /usr/lib/python2.7/site-packages/thrift /usr/lib/python2.7/dist-packages
sudo ldconfig
cd "${START_DIR}/thrift" \
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
        && make -j$(($(nproc)-1)) \
        && sudo make -j$(($(nproc)-1)) install
        # note: might be python3.6 for normal ubuntu 16.04 installs, but is 3.5 for tx2
        && sudo cp -r /usr/lib/python3.5/site-packages/thrift /usr/lib/python3/dist-packages
sudo ldconfig

# build volk (inside gnuradio)
cd "${START_DIR}"
git clone --recursive --branch maint-3.7 https://github.com/gnuradio/gnuradio.git
mkdir -p "${START_DIR}/gnuradio/volk/build"
cd "${START_DIR}/gnuradio/volk/build"
cmake -DCMAKE_BUILD_TYPE=Release ../
make -j$(($(nproc)-1))
sudo make install
sudo ldconfig

# build gnuradio (cloned in volk step)
# NOTE: cmake for Gen2-UHF-RFID-Reader requires gnuradio-v3.7.2
cd "${START_DIR}/gnuradio"
git submodule update --init --recursive
mkdir -p "${START_DIR}/gnuradio/build"
cd "${START_DIR}/gnuradio/build" \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS=-fPIC \
        -DCMAKE_C_FLAGS=-fPIC \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        ../ \
    && make -j$(($(nproc)-1)) \
    && sudo make install \
    && sudo ldconfig

# build Gen2-UHF-RFID-Reader
cd "${START_DIR}" \
    && (test -d Gen2-UHF-RFID-Reader || git clone --recursive https://github.com/nkargas/Gen2-UHF-RFID-Reader.git) \
    && mkdir -p "${START_DIR}/Gen2-UHF-RFID-Reader/gr-rfid/build" \
    && cd "${START_DIR}/Gen2-UHF-RFID-Reader/gr-rfid/build" \
    && cmake DCMAKE_BUILD_TYPE=Release ../ \
    && make -j$(($(nproc)-1)) \
    && sudo make -j$(($(nproc)-1)) install \
    && sudo ldconfig

