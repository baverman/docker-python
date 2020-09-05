FROM alpine:3.5 as base
RUN apk --no-cache add expat libffi readline libbz2 xz-libs gdbm sqlite-libs libstdc++ libcrypto1.0 openssl


FROM base as deps
RUN apk --no-cache add \
        ca-certificates build-base libffi-dev openssl-dev \
        linux-headers pcre-dev file zlib-dev sqlite-dev expat-dev bzip2-dev \
        xz-dev ncurses-dev gdbm-dev readline-dev openssl

ARG SRC=http://www.python.org/ftp/python/2.6.9/Python-2.6.9.tgz
ARG SRC_MD5=bddbd64bf6f5344fc55bbe49a72fe4f3

RUN wget $SRC -O source.tgz \
  && md5sum source.tgz \
  && echo "$SRC_MD5  source.tgz" | md5sum -c \
  && tar xf source.tgz

COPY *.patch /

ENV CPPFLAGS="-DOPENSSL_NO_SSL3"

RUN cd Python* \
  && patch -p1 < ../python-2.6-posix-module.patch \
  && ./configure --prefix=/usr \
                 --enable-shared \
                 --with-threads \
                 --with-system-ffi \
                 --enable-unicode=ucs4 \
  && make -j4

RUN cd Python* \
  && make -j1 DESTDIR=/python altinstall

RUN strip --strip-all /python/usr/lib/python*/lib-dynload/*.so \
  && ln -s /usr/bin/python2.6 /python/usr/bin/python

COPY *.whl *.zip *.tar.gz /

RUN cd / \
  && unzip setuptools-36.8.0.zip \
  && cd setuptools-36.8.0 \
  && LD_LIBRARY_PATH=/python/usr/lib /python/usr/bin/python2.6 setup.py install

RUN cd / \
  && tar xf pip-9.0.3.tar.gz \
  && cd pip-9.0.3 \
  && LD_LIBRARY_PATH=/python/usr/lib /python/usr/bin/python2.6 setup.py install

RUN cd / \
  && LD_LIBRARY_PATH=/python/usr/lib LDFLAGS="-L/python/usr/lib" /python/usr/bin/pip install --disable-pip-version-check \
         asn1crypto-1.3.0-py2.py3-none-any.whl six-1.5.2-py2.py3-none-any.whl \
         pycparser-2.18.tar.gz  cffi-1.14.0.tar.gz enum34-1.1.10-py2-none-any.whl \
         idna-2.7-py2.py3-none-any.whl ipaddress-1.0.23-py2.py3-none-any.whl \
         certifi-2020.4.5.1-py2.py3-none-any.whl cryptography-2.1.4.tar.gz \
         pyOpenSSL-17.5.0-py2.py3-none-any.whl

RUN patch /python/usr/lib/python2.6/site-packages/pip-9.0.3-py2.6.egg/pip/__init__.py pip-pyopenssl.patch
RUN sed -i '1c#!/usr/bin/python' /python/usr/bin/pip

RUN rm -rf /python/usr/lib/python*/test \
           /python/usr/lib/python*/config/libpython*.a \
           /python/usr/lib/python*/idlelib \
           /python/usr/lib/python*/lib2to3/tests \
           /python/usr/lib/python*/email/test \
           /python/usr/lib/python*/ctypes/test


FROM base
COPY --from=deps /python/usr /usr
