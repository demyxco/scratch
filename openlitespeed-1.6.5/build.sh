#!/bin/sh

# Contributor: Valery Kartel <valery.kartel@gmail.com>
# Maintainer: Valery Kartel <valery.kartel@gmail.com>
pkgname=litespeed
pkgver=1.6.5
pkgrel=0
_pkgreal=open$pkgname
_pkghome=var/lib/$pkgname
_php=php7
pkgdesc="High-performance, lightweight, open source HTTP server"
url="https://open.litespeedtech.com"
arch="x86 x86_64 armhf armv7"
license="GPL-3.0"
pkgusers=litespeed
pkggroups=litespeed
depends="$_php-$pkgname $_php-bcmath $_php-json $_php-mcrypt $_php-session $_php-sockets $_php-posix"
depends_dev=
makedepends="linux-headers openssl-dev geoip-dev expat-dev pcre-dev zlib-dev
	bsd-compat-headers lua-dev luajit-dev brotli-dev"
install="$pkgname.pre-install"
subpackages="$pkgname-openrc $pkgname-snmp::noarch"
source="https://openlitespeed.org/packages/openlitespeed-$pkgver.src.tgz
	$pkgname.initd
	include.patch
	install.patch
	ls_lock.patch
	thread.patch
	"
builddir="/openlitespeed-$pkgver"

build() {
	cd "$builddir"
	./configure \
		--host=$CHOST \
		--build=$CBUILD \
		--prefix=/$_pkghome \
		--with-user=$pkgusers \
		--with-group=$pkggroups \
		--enable-adminssl=no \
		--disable-rpath \
		--disable-static \
		--with-openssl=/usr \
		--with-expat \
		--with-pcre \
		--with-lua \
		--with-brotli=/usr/lib/ \
		--with-zlib
	make
}

#package() {
	local file;
	cd "$builddir"
	make DESTDIR="$pkgdir" install

	mkdir -p "$pkgdir"/usr/lib/$pkgname \
		"$pkgdir"/usr/sbin \
		"$pkgdir"/var/log

	# remove trash
	rm -fr "$pkgdir"/$_pkghome/php* \
		"$pkgdir"/$_pkghome/lib \
		"$pkgdir"/$_pkghome/GPL* \
		"$pkgdir"/$_pkghome/gdata \
		"$pkgdir"/$_pkghome/autoupdate \
		"$pkgdir"/$_pkghome/fcgi-bin/* \
		"$pkgdir"/$_pkghome/bin/lshttpd \
		"$pkgdir"/$_pkghome/admin/conf/php.* \
		"$pkgdir"/$_pkghome/admin/misc/gdb-bt \
		"$pkgdir"/$_pkghome/admin/misc/convertxml.* \
		"$pkgdir"/$_pkghome/admin/misc/build_admin_php.sh

	# fix ownership
	chown -R $pkgusers:$pkggroups \
		"$pkgdir"/$_pkghome/tmp \
		"$pkgdir"/$_pkghome/conf \
		"$pkgdir"/$_pkghome/logs \
		"$pkgdir"/$_pkghome/backup \
		"$pkgdir"/$_pkghome/cachedata \
		"$pkgdir"/$_pkghome/admin/tmp \
		"$pkgdir"/$_pkghome/admin/logs \
		"$pkgdir"/$_pkghome/admin/conf \
		"$pkgdir"/$_pkghome/admin/cgid \
		"$pkgdir"/$_pkghome/Example/logs

	# install configs
	install -Dm755 "$srcdir"/$pkgname.initd \
		"$pkgdir"/etc/init.d/$pkgname
	mv "$pkgdir"/$_pkghome/conf \
		"$pkgdir"/etc/$pkgname
	mv "$pkgdir"/$_pkghome/admin/conf \
		"$pkgdir"/etc/$pkgname/admin
	ln -s /etc/$pkgname "$pkgdir"/$_pkghome/conf
	ln -s /etc/$pkgname/admin "$pkgdir"/$_pkghome/admin/conf
	find "$pkgdir"/etc/$pkgname -type f -print0 | xargs -0 chmod -x

	# install binary
	mv "$pkgdir"/$_pkghome/bin/$_pkgreal \
		"$pkgdir"/usr/sbin/lshttpd
	ln -sf /usr/sbin/lshttpd \
		"$pkgdir"/$_pkghome/bin/$pkgname

	# install modules
	for file in $(find "$pkgdir"/$_pkghome/modules -name "*.so"); do
		mv $file "$pkgdir"/usr/lib/$pkgname/${file##*/}
		ln -s /usr/lib/$pkgname/${file##*/} $file
	done

	# install logs
	mv "$pkgdir"/$_pkghome/logs "$pkgdir"/var/log/$pkgname
	mv "$pkgdir"/$_pkghome/admin/logs "$pkgdir"/var/log/$pkgname/admin
	mv "$pkgdir"/$_pkghome/Example/logs "$pkgdir"/var/log/$pkgname/Example
	ln -s /var/log/$pkgname "$pkgdir"/$_pkghome/logs
	ln -s /var/log/$pkgname/admin "$pkgdir"/$_pkghome/admin/logs
	ln -s /var/log/$pkgname/Example "$pkgdir"/$_pkghome/Example/logs

	# install backend
	ln -s /usr/bin/ls$_php "$pkgdir"/$_pkghome/fcgi-bin/lsphp
	ln -s /etc/$_php/php.ini "$pkgdir"/etc/$pkgname/php.ini
	ln -s /etc/$_php/php.ini "$pkgdir"/etc/$pkgname/admin/php.ini
#}

#snmp() {
	pkgdesc="$pkgdesc (snmp monitoring add-on + cacti templates)"
	depends="$pkgname net-snmp"

	mkdir -p "$subpkgdir"/$_pkghome/add-ons
	mv "$pkgdir"/$_pkghome/add-ons/snmp_monitoring \
		"$subpkgdir"/$_pkghome/add-ons
#}
