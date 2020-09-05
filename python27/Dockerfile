FROM alpine:3.11 as base
RUN apk --no-cache add expat libffi readline libbz2 xz-libs gdbm sqlite-libs libstdc++


FROM base as deps

RUN apk --no-cache add \
        ca-certificates build-base libffi-dev openssl-dev \
        linux-headers pcre-dev file zlib-dev sqlite-dev expat-dev bzip2-dev \
        xz-dev ncurses-dev gdbm-dev readline-dev

ARG SRC=http://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
ARG SRC_MD5=38c84292658ed4456157195f1c9bcbe1

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
  && patch -p1 < /patches/unchecked-ioctl.patch \
  && rm -r Modules/expat \
           Modules/zlib \
           Modules/_ctypes/libffi* \
  && export OPT="$CFLAGS -DTHREAD_STACK_SIZE=0x100000" \
  && ./configure --prefix=/usr \
                 --enable-ipv6 \
                 --enable-loadable-sqlite-extensions \
                 --enable-shared \
                 --enable-unicode=ucs4 \
                 --with-system-expat \
                 --with-system-ffi \
                 --with-system-zlib \
                 --with-ensurepip=install \
                 --with-threads \
  && make -j4

RUN cd Python* \
  && make -j4 DESTDIR=/python install \
  && strip --strip-all /python/usr/lib/python*/lib-dynload/*.so

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
           /python/usr/lib/python*/config-*m-x86_64-linux-gnu \
           /python/usr/lib/python*/config-*m/ \
           /python/usr/bin/idle*


FROM base
COPY --from=deps /python/usr /usr
