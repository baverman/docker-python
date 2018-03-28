FROM alpine:3.7 as base
RUN apk --no-cache add expat libffi


FROM base as deps

RUN apk --no-cache add \
        ca-certificates build-base libffi-dev libressl-dev \
        linux-headers pcre-dev file zlib-dev sqlite-dev expat-dev bzip2-dev \
        xz-dev ncurses-dev gdbm-dev readline-dev

ARG SRC=https://www.python.org/ftp/python/3.5.5/Python-3.5.5.tgz
ARG SRC_MD5=7c825b747d25c11e669e99b912398585

ENV CFLAGS="-Os -fomit-frame-pointer" \
    CXXFLAGS="-Os -fomit-frame-pointer" \
    CPPFLAGS="-Os -fomit-frame-pointer" \
    LDFLAGS="-Wl,--as-needed"

RUN wget $SRC -O source.tgz \
  && echo "$SRC_MD5  source.tgz" | md5sum -c \
  && tar xf source.tgz

COPY /*.patch /patches/

RUN cd Python* \
  && patch -p1 < /patches/musl-find_library.patch \
  && patch -p1 < /patches/fix-xattrs-glibc.patch \
  && patch -p1 < /patches/bpo-30353.patch \
  && patch -p1 < /patches/libressl.patch \
  && rm -r Modules/expat \
           Modules/zlib \
           Modules/_ctypes/darwin* \
           Modules/_ctypes/libffi* \
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
  && make -j2 EXTRA_CFLAGS="$CFLAGS -DTHREAD_STACK_SIZE=0x100000"

RUN cd Python* \
  && make -j1 DESTDIR=/python EXTRA_CFLAGS="$CFLAGS" install \
  && strip --strip-all /python/usr/lib/python*/lib-dynload/*.so \
  && ln -s /usr/bin/python3 /python/usr/bin/python \
  && ln -s /usr/bin/pip3 /python/usr/bin/pip

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
           /python/usr/lib/python*/config-*m/libpython*m.a \
           /python/usr/bin/idle*


FROM base
COPY --from=deps /python/usr /usr
