ARG _INSTALL_BASE_IMAGE=alpine:3.11

FROM ${_INSTALL_BASE_IMAGE} as base
ARG _INSTALL_SSL_LIBS="libssl1.1 libcrypto1.1"
RUN env
RUN apk --no-cache add expat libffi readline libbz2 xz-libs gdbm sqlite-libs libstdc++ ${_INSTALL_SSL_LIBS}

FROM base as deps
RUN apk --no-cache add \
        ca-certificates build-base libffi-dev openssl openssl-dev \
        linux-headers pcre-dev file zlib-dev sqlite-dev expat-dev bzip2-dev \
        xz-dev ncurses-dev gdbm-dev readline-dev

ARG SRC
ARG SRC_MD5
ARG PYLIB

ENV CFLAGS="-Os -fomit-frame-pointer" \
    CXXFLAGS="-Os -fomit-frame-pointer" \
    CPPFLAGS="-Os -fomit-frame-pointer" \
    LDFLAGS="-Wl,--as-needed"

RUN wget $SRC -O source.tgz \
  && md5sum source.tgz \
  && echo "$SRC_MD5  source.tgz" | md5sum -c \
  && tar xf source.tgz

COPY /*.patch /patches/

RUN cd Python* \
  && patch -p1 < /patches/musl-find_library.patch \
  && patch -p1 < /patches/fix-xattrs-glibc.patch \
  && ( rm -r Modules/expat \
           Modules/zlib \
           Modules/_ctypes/darwin* \
           Modules/_ctypes/libffi* || true ) \
  && ./configure --prefix=/usr \
                 --enable-ipv6 \
                 --enable-loadable-sqlite-extensions \
                 --enable-shared \
                 --with-lto \
                 --with-computed-gotos \
                 --with-dbmliborder=gdbm:ndbm \
                 --with-system-expat \
                 --with-system-ffi \
                 --with-threads \
  && make -j4 EXTRA_CFLAGS="$CFLAGS -DTHREAD_STACK_SIZE=0x100000"

RUN cd Python* \
  && make -j4 DESTDIR=/python EXTRA_CFLAGS="$CFLAGS" install \
  && strip --strip-all /python/usr/lib/python*/lib-dynload/*.so \
  && ln -s /usr/bin/python3 /python/usr/bin/python \
  && ln -s /usr/bin/pip3 /python/usr/bin/pip \
  && echo "manylinux1_compatible = True" > /python/usr/lib/$PYLIB/_manylinux.py


RUN rm -rf /python/usr/lib/python*/test \
           /python/usr/lib/python*/idlelib \
           /python/usr/lib/python*/tkinter \
           /python/usr/lib/python*/pydoc_data \
           /python/usr/lib/python*/ensurepip \
           /python/usr/lib/python*/unittest/test \
           /python/usr/lib/python*/ctypes/test \
           /python/usr/lib/python*/distutils/tests \
           /python/usr/lib/python*/lib2to3/tests \
           /python/usr/lib/python*/sqlite3/test \
           /python/usr/lib/python*/turtledemo \
           /python/usr/lib/python*/config-*/libpython*.a \
           /python/usr/bin/idle*


FROM base
COPY --from=deps /python/usr /usr
