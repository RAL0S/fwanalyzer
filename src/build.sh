#!/bin/sh

set -e

mkdir build

echo "Building e2tools..."
apk update
apk add e2fsprogs-dev e2fsprogs-static alpine-sdk
wget https://github.com/e2tools/e2tools/releases/download/v0.1.0/e2tools-0.1.0.tar.gz
tar xf e2tools-0.1.0.tar.gz
cd e2tools-0.1.0/
./configure --prefix=/root/build LDFLAGS=-static
make
make install
cd ..

echo "Building mtools..."
wget http://ftp.gnu.org/gnu/mtools/mtools-4.0.40.tar.gz
tar xf mtools-4.0.40.tar.gz
cd mtools-4.0.40/
./configure --prefix=/root/build LDFLAGS=-static
make
make install
cd ..

echo "Building file..."
wget http://ftp.astron.com/pub/file/file-5.41.tar.gz
tar xf file-5.41.tar.gz
cat<<EOF >gcc
#!/bin/sh
/usr/bin/gcc -static "\$@"
EOF
chmod +x gcc
cd file-5.41
./configure --prefix=/root/build --enable-static=yes --enable-shared=no LDFLAGS=-static
PATH=/root/:$PATH make
make install
cd ..

echo "Building squashfs-tools..."
apk add xz-dev zlib-dev zlib-static lzo-dev lz4-dev lz4-static zstd-dev zstd-static
wget  https://downloads.sourceforge.net/project/squashfs/squashfs/squashfs4.5.1/squashfs-tools-4.5.1.tar.gz
tar xf squashfs-tools-4.5.1.tar.gz
cd squashfs-tools-4.5.1/squashfs-tools
sed -i 's/^#XZ_SUPPORT/XZ_SUPPORT/; s/^#LZO_SUPPORT/LZO_SUPPORT/;  s/^#LZ4_SUPPORT/LZ4_SUPPORT/; s/^#ZSTD_SUPPORT/ZSTD_SUPPORT/' Makefile
sed -i '/^INSTALL_PREFIX/ c INSTALL_PREFIX=/root/build/' Makefile
make LDFLAGS=-static
make install
cd ../..

echo "Building unzip..."
wget https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz
tar xf unzip60.tar.gz
cd unzip60
sed -i 's/^LF =/LF =-static/; s/^SL =/SL =-static/; s/^FL =/FL =-static/' unix/Makefile
sed -i '/^prefix =/ c prefix = /root/build/' unix/Makefile
make -f unix/Makefile generic
make -f unix/Makefile install
cd ..

echo "Building cpio..."
wget https://ftp.gnu.org/gnu/cpio/cpio-2.13.tar.gz
tar xf cpio-2.13.tar.gz
cd cpio-2.13/
#https://bugs.gentoo.org/705900
#https://wiki.gentoo.org/wiki/Project:Toolchain/Gcc_10_porting_notes/fno_common
./configure --prefix=/root/build LDFLAGS=-static --enable-mt CFLAGS=-fcommon
make
make install
cd ..

echo "Building fwanalyzer binaries..."
apk add go
git clone https://github.com/cruise-automation/fwanalyzer
cd fwanalyzer
make deps
CGO_ENABLED=0 make
mv build/fwanalyzer /root/build/bin/
cd ..

(cd build && tar czf ../fwanalyzer-build.tar.gz *)
