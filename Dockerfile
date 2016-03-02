FROM ubuntu:trusty
MAINTAINER Adrien André <adr.andre@laposte.net>

# TerraLib (GIS library)
#   Site: http://www.terralib.org
#   Doxygen: http://www.terralib.org/html/v410/index.html
# InterIMAGE
#   http://tolomeofp7.unipv.it/SoftwareTools/InterIMAGE
#   http://www.lvc.ele.puc-rio.br/projects/interimage
# Installation
#   http://www.lvc.ele.puc-rio.br/projects/interimage/download/files/install_interimage_ubuntu.txt
#
# See: http://courses.neteler.org/fun-docker-grass-gis-software

RUN apt-get update && apt-get -y upgrade && apt-get clean


RUN apt-get install -y wget nano emacs24-nox tree unzip \
    cmake-curses-gui \
    cmake subversion build-essential gdb && \
    apt-get clean


ENV DIR_DEV /opt/src

RUN mkdir $DIR_DEV
RUN mkdir $DIR_DEV/terralib
RUN mkdir $DIR_DEV/interimage
WORKDIR $DIR_DEV



# # Make SVN accept INPE DPI certificate
# RUN openssl s_client -connect svn.dpi.inpe.br:443 -showcerts | \
#     openssl x509 -outform PEM > \
#     /etc/ssl/certs/Instituto_Nacional_de_Pesquisas_Espaciais.pem
# RUN sed -i '/CAcert.pem/a ssl-authority-files = /etc/ssl/certs/Instituto_Nacional_de_Pesquisas_Espaciais.pem' /etc/subversion/servers
# RUN sed -i '/CAcert.pem/a ssl-trust-default-ca = true' /etc/subversion/servers



# Dependencies
RUN apt-get install -y \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libgeotiff-dev \
    libgdal1-dev \
    freeglut3-dev \
    libqwt-dev \
    libpq-dev \
    qt4-default qt4-qmake && \
    apt-get clean

COPY diff /tmp/diff



# TerraLib installation
ENV VERSION_TERRALIB 4-3-0
#RUN wget -nv -c http://www.lvc.ele.puc-rio.br/projects/interimage/download/files/terralib_cvs.zip && unzip -d terralib terralib_cvs.zip
#RUN apt-get install -y libterralib libterralib-dev libterralib-doc
#RUN echo t | svn co https://svn.dpi.inpe.br/terralib/tags/v-${VERSION_TERRALIB} terralib/${VERSION_TERRALIB}
COPY terralib/${VERSION_TERRALIB} $DIR_DEV/terralib

WORKDIR $DIR_DEV/terralib
RUN cd $DIR_DEV/terralib/src && patch -p0 -i /tmp/diff/tl/yyTemporal
RUN cd $DIR_DEV/terralib/src && patch -p0 -i /tmp/diff/tl/TeConnectionPool
RUN cd $DIR_DEV/terralib/src && patch -p0 -i /tmp/diff/tl/TeApplicationUtils
RUN cd $DIR_DEV/terralib/src && patch -p0 -i /tmp/diff/tl/TeEWKBDriver

RUN mkdir bin
RUN cmake -D BUILD_TERRAVIEW=OFF CMAKE_INSTALL_PREFIX=$DIR_DEV/terralib/bin \
      -D GeoTIFF_INCLUDE_DIR=/usr/include/geotiff -D GeoTIFF_LIBRARY=/usr/lib/libgeotiff.so \
      -D JPEG_INCLUDE_DIR=/usr/include -D JPEG_LIBRARY=/usr/lib/x86_64-linux-gnu/libjpeg.so \
      -D TIFF_INCLUDE_DIR=/usr/include/x86_64-linux-gnu -D TIFF_LIBRARY=/usr/lib/x86_64-linux-gnu/libtiff.so \
      -D ZLIB_INCLUDE_DIR=/usr/include-D ZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so \
      -D PostGIS_INCLUDE_DIR=/usr/include/postgresql -D PostgreSQL_LIBRARY=/usr/lib/libpq.so \
      -D GLUT_INCLUDE_DIR=/usr/include/GL -D GLUT_LIBRARY=/usr/lib/x86_64-linux-gnu/libglut.so \
      -D QWT_INCLUDE_DIR=/usr/include/qwt \
      build/cmake && \
    make



# TerraAida installation
#RUN svn co https://svn.dpi.inpe.br/terraaida/trunk terraaida
COPY terraaida $DIR_DEV/terraaida

WORKDIR $DIR_DEV/terraaida
RUN patch -p0 -i /tmp/diff/ta/ta_operators_base


WORKDIR	$DIR_DEV/terraaida/ta_operators/build/linux-g++

# RUN export TA_TERRALIB_PATH=$DIR_DEV/terralib ; \
#     export TA_TERRALIB_SRC_PATH=$DIR_DEV/terralib/src ; export TA_TERRALIB_BIN_PATH=$DIR_DEV/terralib/bin ; \
#     export TA_TIF_SRC_PATH=/usr/include/x86_64-linux-gnu ; export TA_TIF_BIN_PATH=/usr/lib/x86_64-linux-gnu/libtiff.so ; \
#     export TA_GEOTIF_SRC_PATH=/usr/include/geotiff ; export TA_GEOTIF_BIN_PATH=/usr/lib/libgeotiff.so ; \
#     export TA_JPG_SRC_PATH=/usr/include ; export TA_JPG_BIN_PATH=/usr/lib/x86_64-linux-gnu/libjpeg.so ; \
#     export TA_CPPUNIT_SRC_PATH= ; export TA_CPPUNIT_BIN_PATH= ; \
#     qmake -r && make clean && make



# InterIMAGE installation
ENV VERSION_INTERIMAGE 1.43
#RUN wget -nv -c -O interimage-${VERSION_INTERIMAGE}.zip "http://www.lvc.ele.puc-rio.br/projects/interimage/download/files/InterIMAGE%20Source%20${VERSION_INTERIMAGE}.zip" && \
#    unzip interimage-${VERSION_INTERIMAGE}.zip && \
#    mv InterIMAGE\ Source\ 1.43 interimage
COPY interimage $DIR_DEV/interimage

WORKDIR $DIR_DEV/interimage

RUN qmake -r && make clean && make
