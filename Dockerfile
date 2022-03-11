FROM ubuntu:focal

ENV THRIFT_VERSION 0.16.0
ENV PACKAGE_REVISION 1
ENV CXX_PN libthrift
ENV CXX_PACKAGE ${CXX_PN}_${THRIFT_VERSION}-${PACKAGE_REVISION}
ENV C_PN libthriftc
ENV C_PACKAGE ${C_PN}_${THRIFT_VERSION}-${PACKAGE_REVISION}
ENV BIN_PN thrift
ENV BIN_PACKAGE ${BIN_PN}_${THRIFT_VERSION}-${PACKAGE_REVISION}
ENV PREFIX usr/local
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt install -y build-essential git autoconf automake libtool pkg-config libboost-all-dev bison flex curl libglib2.0-dev libssl-dev dh-make bzr-builddeb libevent-dev

RUN curl -L -o thrift-${THRIFT_VERSION}.tar.gz "https://github.com/apache/thrift/archive/v${THRIFT_VERSION}.tar.gz"
RUN tar xpvzf thrift-${THRIFT_VERSION}.tar.gz
WORKDIR thrift-${THRIFT_VERSION}
RUN sh bootstrap.sh
RUN ./configure --disable-python --disable-py3 --disable-tests
RUN make -j4

# How to make a 'basic' .deb
# See https://ubuntuforums.org/showthread.php?t=910717

WORKDIR ../thrift-${THRIFT_VERSION}
RUN make -j4 DESTDIR=`pwd`/../${CXX_PACKAGE} install
WORKDIR ../${CXX_PACKAGE}
# get rid of binaries (please install thrift-compiler for that)
RUN rm -Rf ${PREFIX}/bin
# get rid of python2.7 directory (also uses wrong prefix)
RUN rm -Rf usr/lib
# get rid of c_glib artifacts
RUN rm -Rf ${PREFIX}/lib/*c_glib* ${PREFIX}/lib/pkgconfig/*c_glib* ${PREFIX}/include/thrift/c_glib
RUN mkdir -p DEBIAN
RUN echo "Package: ${CXX_PN}" > DEBIAN/control
RUN echo "Version: ${THRIFT_VERSION}-${PACKAGE_REVISION}" >> DEBIAN/control
RUN echo "Section: base" >> DEBIAN/control
RUN echo "Priority: optional" >> DEBIAN/control
RUN echo "Architecture: `dpkg --print-architecture`" >> DEBIAN/control
#RUN echo "Depends: libboost-all-dev, libevent-dev, libssl, zlib1g" >> DEBIAN/control
RUN echo "Maintainer: Christopher Friedt <chrisfriedt@gmail.com>" >> DEBIAN/control
RUN echo "Description: Apache Thrift C++ Bindings" >> DEBIAN/control
RUN echo " These are the C++ runtime libraries development files" >> DEBIAN/control
RUN echo " for Apache Thrift" >> DEBIAN/control
WORKDIR ..
RUN dpkg-deb --build ${CXX_PACKAGE}

WORKDIR ../thrift-${THRIFT_VERSION}
RUN make -j4 DESTDIR=`pwd`/../${C_PACKAGE} install
WORKDIR ../${C_PACKAGE}
# get rid of binaries (please install thrift-compiler for that)
RUN rm -Rf ${PREFIX}/bin
# get rid of python2.7 directory (also uses wrong prefix)
RUN rm -Rf usr/lib
# get rid of c++ artifacts
RUN rm -Rf ${PREFIX}/lib/libthrift.* ${PREFIX}/lib/libthrift-* ${PREFIX}/lib/libthriftz.* ${PREFIX}/lib/libthriftz-* ${PREFIX}/lib/libthriftnb.* ${PREFIX}/lib/libthriftnb-0* ${PREFIX}/lib/pkgconfig/thrift.* ${PREFIX}/lib/pkgconfig/thrift-z.*  ${PREFIX}/lib/pkgconfig/thrift-nb.*
# get rid of c++ includes
RUN cd ${PREFIX}/include/thrift; rm -f *.h; rm -Rf qt processor server async protocol transport concurrency
RUN mkdir -p DEBIAN
RUN echo "Package: ${C_PN}" > DEBIAN/control
RUN echo "Version: ${THRIFT_VERSION}-${PACKAGE_REVISION}" >> DEBIAN/control
RUN echo "Section: base" >> DEBIAN/control
RUN echo "Priority: optional" >> DEBIAN/control
RUN echo "Architecture: `dpkg --print-architecture`" >> DEBIAN/control
#RUN echo "Depends: libevent-dev, libglib2.0, libssl, zlib1g" >> DEBIAN/control
RUN echo "Maintainer: Christopher Friedt <chrisfriedt@gmail.com>" >> DEBIAN/control
RUN echo "Description: Apache Thrift C (Glib) Bindings" >> DEBIAN/control
RUN echo " These are the C (Glib) runtime libraries development files" >> DEBIAN/control
RUN echo " for Apache Thrift" >> DEBIAN/control
WORKDIR ..
RUN dpkg-deb --build ${C_PACKAGE}

WORKDIR ../thrift-${THRIFT_VERSION}
RUN make -j4 DESTDIR=`pwd`/../${BIN_PACKAGE} install
WORKDIR ../${BIN_PACKAGE}
# get rid of python2.7 directory (also uses wrong prefix)
RUN rm -Rf usr/lib
# get rid of non-binary artifacts
RUN rm -Rf ${PREFIX}/lib ${PREFIX}/include
RUN mkdir -p DEBIAN
RUN echo "Package: ${BIN_PN}" > DEBIAN/control
RUN echo "Version: ${THRIFT_VERSION}-${PACKAGE_REVISION}" >> DEBIAN/control
RUN echo "Section: base" >> DEBIAN/control
RUN echo "Priority: optional" >> DEBIAN/control
RUN echo "Architecture: `dpkg --print-architecture`" >> DEBIAN/control
#RUN echo "Depends: libevent-dev, libglib2.0, libssl, zlib1g" >> DEBIAN/control
RUN echo "Maintainer: Christopher Friedt <chrisfriedt@gmail.com>" >> DEBIAN/control
RUN echo "Description: Apache Thrift Compiler" >> DEBIAN/control
RUN echo " The Apache Thrift compiler" >> DEBIAN/control
WORKDIR ..
RUN dpkg-deb --build ${BIN_PACKAGE}
