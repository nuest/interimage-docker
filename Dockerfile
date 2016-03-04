FROM ubuntu:trusty
MAINTAINER Adrien André <adr.andre@laposte.net>

# Installation
#   http://www.lvc.ele.puc-rio.br/projects/interimage/download/files/install_interimage_ubuntu.txt

RUN apt-get update && apt-get -y upgrade && apt-get clean


RUN apt-get install -y wget nano emacs24-nox tree unzip \
    cmake-curses-gui \
    cmake subversion build-essential gdb && \
    apt-get clean


ENV DIR_DEV /opt/src

RUN mkdir $DIR_DEV
RUN mkdir $DIR_DEV/interimage

WORKDIR $DIR_DEV



# Dependencies
RUN apt-get install -y \
      zlib1g-dev \
      libtiff5-dev libjpeg-dev \
      libgeotiff-dev libgdal1-dev \
      freeglut3-dev libqwt-dev \
      libpq-dev \
      libcppunit-dev \
      qt4-default qt4-qmake && \
    apt-get clean



# InterIMAGE installation
ENV VERSION_INTERIMAGE 1.27
RUN wget -nv -c -O interimage-${VERSION_INTERIMAGE}.tar.gz http://www.lvc.ele.puc-rio.br/projects/interimage/download/files/InterIMAGE_${VERSION_INTERIMAGE}_Linux.tar.gz && \
    tar zxv -C interimage -f interimage-${VERSION_INTERIMAGE}.tar.gz

WORKDIR $DIR_DEV/interimage

WORKDIR $DIR_DEV/interimage/terralib_cvs/terralibmw

RUN qmake -r && make clean
RUN make

RUN find Debug -type f -name "lib*.so*" -exec cp {} /usr/local/lib/ \;
RUN for lib in gaimage shape_file_editor local_engine ta_tdbu image_visualization bottomupgui qtparser ; do \
      cp $DIR_DEV/interimage/bin_${VERSION_INTERIMAGE}/bin/lib${lib}.so.1.0.0 /usr/local/lib/ ; \
    done
# FIXME: This is dirty. Use cp --preserve=links ?
WORKDIR /usr/local/lib/
RUN for lib in libshapelib libterralib libterralibpdi libterralibtiff gaimage shape_file_editor local_engine ta_tdbu image_visualization bottomupgui qtparser ; do \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1 ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1.0 ; \
    done



# TA Operators
WORKDIR $DIR_DEV/interimage/ta_operators/build/linux-g++
RUN TA_TERRALIB_PATH=$DIR_DEV/interimage/terralib_cvs qmake -r && make clean
RUN make
WORKDIR $DIR_DEV/interimage

RUN find ta_operators/bin/Debug -type f -name "lib*.so*" -exec cp {} /usr/local/lib/ \;
# FIXME: This is dirty:
WORKDIR /usr/local/lib/
RUN for lib in ta_operators_base ; do \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1 ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1.0 ; \
    done
WORKDIR $DIR_DEV/interimage
RUN find ta_operators/bin/Debug -type f -name "ta_*" -exec cp {} /usr/local/lib/ \;

RUN ldconfig

RUN mkdir InterIMAGE_Source_${VERSION_INTERIMAGE}/bin
RUN find ta_operators/bin/Debug -type f -name "lib*.so*" -exec cp {} $DIR_DEV/interimage/InterIMAGE_Source_${VERSION_INTERIMAGE}/bin/ \;
# FIXME: This is dirty:
WORKDIR $DIR_DEV/interimage/InterIMAGE_Source_${VERSION_INTERIMAGE}/bin/
RUN for lib in ta_operators_base ; do \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1 ; \
      ln -s lib${lib}.so.1.0.0 lib${lib}.so.1.0 ; \
    done
WORKDIR $DIR_DEV/interimage
RUN find ta_operators/bin/Debug -type f -name "ta_*" -exec cp {} $DIR_DEV/interimage/InterIMAGE_Source_${VERSION_INTERIMAGE}/bin/ \;



## Compilation of InterIMAGE
WORKDIR $DIR_DEV/interimage/InterIMAGE_Source_${VERSION_INTERIMAGE}
RUN qmake -r && make clean
RUN make

WORKDIR $DIR_DEV/interimage
RUN cp -r bin_${VERSION_INTERIMAGE}/bin/help bin_${VERSION_INTERIMAGE}/bin/share InterIMAGE_Source_${VERSION_INTERIMAGE}/bin/

# cd /opt/src/interimage/InterIMAGE_Source_1.27/bin && ./interimage
