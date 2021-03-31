#!/bin/sh -e

BUILDDIR=/tmp/build-tcl

source /etc/os-release
echo "name: (${NAME})"
cat /etc/os-release

case "$ID" in
	alpine)
		apk update
		apk add --no-cache ca-certificates libpq gcc musl-dev libssl1.1 libcrypto1.1
		apk add --no-cache --virtual build-dependencies \
			build-base bsd-compat-headers findutils autoconf automake bash curl openssl-dev curl-dev
		;;
	ubuntu)
		apt-get update
		apt-get install -y zlib1g libpq5 gcc libc-dev
		apt-get install -y build-essential autoconf zlib1g-dev libssl-dev automake curl libcurl4-openssl-dev
		#apt-get install -y vim netcat net-tools
		;;
	*)
		echo "Unsupported OS: $ID" >&2
		exit 1
		;;
esac

cd $BUILDDIR


# Build Tcl
mkdir build_tcl
(
	cd build_tcl
	tar x --strip-components=1 -zf ../tcl.tar.gz
	cd unix
	CFLAGS=-O2 ./configure --enable-64bit --enable-symbols
	make -j 16 all
	make install
	make install-private-headers
	cp ../libtommath/tommath.h /usr/local/include/
	rm -rf /usr/local/share
	make clean
)
test "x$ID" != "xalpine" && ldconfig
ln -s /usr/local/bin/tclsh8.7 /usr/local/bin/tclsh

mkdir tcllib
(
	cd tcllib
	tar xz --strip-components=1 -zf "$BUILDDIR/tcllib.tar.gz"
	./configure
	make install
	make clean
)
rm -rf "$BUILDDIR/tcllib"
rm -rf /usr/local/man

mkdir sqlite
(
	cd sqlite
	tar xz --strip-components=1 -zf "$BUILDDIR/sqlite.tar.gz"
	cd tea
	autoconf
	CFLAGS=-O2 ./configure
	make clean all install
	make clean
)

tar xzf thread.tar.gz
(
	cd thread
	tar xzf "$BUILDDIR/tclconfig.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all
	make install
	make clean
)

mkdir tdbc
(
	cd tdbc
	tar xz --strip-components=1 -zf "$BUILDDIR/tdbc.tar.gz"
	tar xzf "$BUILDDIR/tclconfig.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install
	make clean
)

mkdir tdbcpostgres
(
	cd tdbcpostgres
	tar xz --strip-components=1 -zf "$BUILDDIR/tdbcpostgres.tar.gz"
	tar xzf "$BUILDDIR/tclconfig.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols --with-tdbc=/usr/local/lib/tdbc1.1.1
	make clean all install
	make clean
)

mkdir build_tdom
(
	cd build_tdom
	tar xz --strip-components=1 -zf "$BUILDDIR/tdom.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install
	make clean
)

tar xzf tcltls.tar.gz
(
	cd tcltls
	tar xzf "$BUILDDIR/tclconfig.tar.gz"
	./autogen.sh
	CFLAGS=-O2 ./configure --prefix=/usr/local --libdir=/usr/local/lib --disable-sslv2 --disable-sslv3 --disable-tlsv1.0 --disable-tlsv1.1 --enable-ssl-fastpath --enable-symbols
	make clean all
	make install
	make clean
)

mkdir build_parse_args
(
	cd build_parse_args
	tar xz --strip-components=1 -zf "$BUILDDIR/parse_args.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install-libraries install-binaries
	make clean
)

mkdir build_rl_json
(
	cd build_rl_json
	tar xz --strip-components=1 -zf "$BUILDDIR/rl_json.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install
	make clean
)

mkdir build_hash
(
	cd build_hash
	tar xz --strip-components=1 -zf "$BUILDDIR/hash.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install-libraries install-binaries
	make clean
)

mkdir build_unix_sockets
(
	cd build_unix_sockets
	tar xz --strip-components=1 -zf "$BUILDDIR/unix_sockets.tar.gz"
	autoconf
	CFLAGS=-O2 ./configure --enable-symbols
	make clean all install-libraries install-binaries
	make clean
)

mkdir build_critcl
(
	cd build_critcl
	tar xz --strip-components=1 -zf "$BUILDDIR/critcl.tar.gz"
	./build.tcl install /usr/local/lib
)
echo "Removing $BUILDDIR/build_critcl"
rm -rf "$BUILDDIR/build_critcl"

# Temporary fake openssl binary to support calculating the hashes of downloaded sources
cp fake_openssl /usr/local/bin/openssl
chmod +x /usr/local/bin/openssl
mkdir tcc4tcl
(
	cd tcc4tcl
	tar xz --strip-components=1 -zf "$BUILDDIR/tcc4tcl.tar.gz"
	build/pre.sh
	# Patch the unprotected GNUism in alltypes.h that trips up tcc
	sed --in-place -e 's/^typedef __builtin_va_list \(.*\)/#if defined(__GNUC__) \&\& __GNUC__ >= 3\ntypedef __builtin_va_list \1\n#else\ntypedef char* \1\n#endif/g' /usr/include/bits/alltypes.h
	sed --in-place -e 's/@@VERS@@/0.30.1/g' configure.ac Makefile.in tcc4tcl.tcl
	autoconf
	./configure --prefix=/usr/local
	make clean all install
)
rm /usr/local/bin/openssl

echo "Cleaning up build area"
find $BUILDDIR -type f -not -name '*.c' -and -not -name '*.h' -exec rm {} \;

echo "Cleaning up"
# Clean up
case "$ID" in
	alpine)
		apk del build-dependencies
		;;
	ubuntu)
		apt-get remove -y build-essential autoconf zlib1g-dev libssl-dev automake curl
		apt-get -y autoremove
		apt-get clean
		rm -rf /var/lib/apt/lists/*
		;;
	*)
		echo "Unsupported OS: $ID" >&2
		exit 1
		;;
esac

#echo "Removing $BUILDDIR"
#rm -rf $BUILDDIR || echo "Can't remove $BUILDDIR"

echo "Done, exiting cleanly"
exit 0
