#!/usr/bin/env bash
# to test install: cd ~/Gen2-UHF-RFID-Reader/gr-rfid/apps/ && sudo GR_SCHEDULER=STS nice -n -20 python ./reader.py

START_DIR="$PWD"

# fix python2 depends on ubuntu20 that no longer exist
# ref: https://askubuntu.com/questions/1254347/how-to-get-pyqt5-for-python2-on-ubuntu-20-04
# create the package structure:
cd /tmp
mkdir qtbase-abi-fake
mkdir -p qtbase-abi-fake/DEBIAN
mkdir -p qtbase-abi-fake/usr/lib/qtbase-abi-fake
touch qtbase-abi-fake/usr/lib/qtbase-abi-fake/nothing.txt

# create the deb control file (the guts):
cat <<_EOF > qtbase-abi-fake/DEBIAN/control
Package: qtbase-abi-fake
Version: 5.9.5
Section: custom
Priority: optional
Architecture: all
Essential: no
Installed-Size: 1024
Maintainer: atlas
Description: Fakes out python-pyqt5 from Ubuntu 18.04 to work on 20.04
Provides: qtbase-abi-5-9-5
_EOF

# build the qtbase-abi-fake.deb file:
dpkg-deb --build qtbase-abi-fake

# install your newly created deb file:
sudo dpkg -i qtbase-abi-fake.deb

# add bionic to apt repos:
echo 'deb http://us.archive.ubuntu.com/ubuntu/ bionic universe multiverse' | sudo tee /etc/apt/sources.list.d/bionic-helper.list

# install instructions from
# https://kb.ettus.com/Building_and_Installing_the_USRP_Open-Source_Toolchain_(UHD_and_GNU_Radio)_on_Linux
# https://github.com/gnuradio/gnuradio-docker/blob/master/ci/ci-ubuntu-20.04-3.9/Dockerfile
sudo apt update -y
sudo apt install -y --no-install-recommends \
    git swig doxygen build-essential libboost-all-dev \
    libtool libusb-1.0-0 libusb-1.0-0-dev libudev-dev \
    libncurses5-dev libfftw3-bin libfftw3-dev libfftw3-doc \
    libcppunit-dev libcppunit-doc ncurses-bin \
    cpufrequtils \
    python-docutils \
    libfftw3-bin libfftw3-dev \
    libfftw3-doc ncurses-bin libncurses5 libncurses5-dev \
    libfontconfig1-dev libxrender-dev libpulse-dev swig g++ automake autoconf \
    libtool libfftw3-dev libcppunit-dev libboost-all-dev libusb-dev \
    libusb-1.0-0-dev fort77 libsdl1.2-dev python-wxgtk3.0 \
    ccache libgsl-dev python-cheetah \
    doxygen libusb-1.0-0-dev \
    git-core wget \
    libxi-dev gtk2-engines-pixbuf r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev \
    libasound2-dev \
    libcomedi-dev python-setuptools libssl-dev bison flex libssl-dev \
    libthrift-dev thrift-compiler ca-certificates appstream-util \
    libuhd-dev libuhd3.15.0 libusb-1.0-0-dev \
    pybind11-dev \
    python3-click-plugins python3-click \
    python-mako python3-mako \
    python-dev python3-dev \
    python3-gi \
    python3-gi-cairo \
    python-lxml python3-lxml \
    python-numpy python-numpy-doc python-numpy-dbg python3-numpy \
    python-opengl python3-opengl \
    python3-pyqt5 \
    python3-yaml \
    python3-zmq \
    python-six python3-six \
    python3-pytest
# dont work:
# libcppunit-1.13-0v5 python-scipy qt4-bin-dbg qt4-default qt4-doclibqt4-dev libqt4-dev-bin
# python-qt4 python-qt4-dbg python-qt4-dev python-qt4-doc libqwt6abi1 libncurses5-dbg
# libqt4-dev qt4-dev-tools libqwt5-qt4-dev libqwtplot3d-qt4-dev pyqt4-dev-tools qt4-doc
# python-qwt5-qt4 python-gtk2 python-requests python-sphinx python-zmq libzmq-dev libzmq1

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
cd "${START_DIR}/log4cpp"
./configure && make -j$(($(nproc)-1)) && make -j$(($(nproc)-1)) install


# build uhd
cd "${START_DIR}"
git clone --recursive --branch v3.14.0.0 https://github.com/EttusResearch/uhd
mkdir -p "${START_DIR}/uhd/host/build"
cd "${START_DIR}/uhd/host/build"
cmake  ../
make -j$(($(nproc)-1))
sudo make -j$(($(nproc)-1)) install
sudo ldconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
python -m pip install requests
sudo python uhd_images_downloader

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
    && make -j$(($(nproc)-1)) && sudo make -j$(($(nproc)-1)) install \
    && mv /usr/lib/python2.7/site-packages/thrift /usr/lib/python2.7/dist-packages
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
    && sudo make -j$(($(nproc)-1)) install \
    && mv /usr/lib/python3.6/site-packages/thrift /usr/lib/python3/dist-packages

# build volk (inside gnuradio)
cd "${START_DIR}"
git clone --recursive --branch maint-3.7 https://github.com/gnuradio/gnuradio.git
mkdir -p "${START_DIR}/gnuradio/volk/build"
cd "${START_DIR}/gnuradio/volk/build"
cmake ../
make -j$(($(nproc)-1))
sudo make install
sudo ldconfig

# build gnuradio
# NOTE: cmake for Gen2-UHF-RFID-Reader requires gnuradio-v3.7.2
mkdir -p "${START_DIR}"
cd "${START_DIR}/gnuradio"
git submodule update --init --recursive
mkdir -p "${START_DIR}/gnuradio/build"
cd "${START_DIR}/gnuradio/build"
cmake -DCMAKE_BUILD_TYPE=Release ../
make -j$(($(nproc)-1))
sudo make install
sudo ldconfig

# build Gen2-UHF-RFID-Reader
cd "${START_DIR}"
git clone --recursive https://github.com/nkargas/Gen2-UHF-RFID-Reader.git
mkdir -p "${START_DIR}/Gen2-UHF-RFID-Reader/gr-rfid/build"
cd "${START_DIR}/Gen2-UHF-RFID-Reader/gr-rfid/build"
cmake ../
make -j$(($(nproc)-1))
sudo make -j$(($(nproc)-1)) install
sudo ldconfig

echo "Build finished, try running..."
echo "cd ${START_DIR}/Gen2-UHF-RFID-Reader/gr-rfid/apps && sudo GR_SCHEDULER=STS nice -n -20 python2 reader.py"
