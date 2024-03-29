# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

inherit git-r3 python-single-r1 xdg

DESCRIPTION="A curses-based client for Tox"
HOMEPAGE="https://github.com/JFreegman/toxic"
#SRC_URI="https://github.com/JFreegman/toxic/archive/v${PV}.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/JFreegman/toxic.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="notification python qrcode +sound +video +X"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

BDEPEND="dev-libs/libconfig"

RDEPEND="
	~net-libs/tox-9999:*
	net-misc/curl
	sys-libs/ncurses:*
	notification? ( x11-libs/libnotify )
	python? ( ${PYTHON_DEPS} )
	qrcode? ( media-gfx/qrencode )
	sound? (
		media-libs/freealut
		media-libs/openal
		net-libs/tox[av]
	)
	video? (
		media-libs/libvpx
		net-libs/tox[av]
		x11-libs/libX11 )"

DEPEND="${RDEPEND}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default
	#prevent man files from being compressed.
	sed -i -e "/gzip/d" cfg/targets/install.mk || die "Unable to prevent compression of man pages."
}

src_configure() {
	export USER_CFLAGS="${CFLAGS}"
	export USER_LDFLAGS="${LDFLAGS}"
	export MIN_LOGGER_LEVEL=DEBUG
	if ! use sound; then
		export DISABLE_AV=1
		export DISABLE_SOUND_NOTIFY=1
	fi
	if ! use video; then
		export DISABLE_VI=1
	fi
	if ! use X; then
		export DISABLE_X11=1
	fi
	if ! use notification; then
		export DISABLE_DESKTOP_NOTIFY=1
	fi
	if ! use qrcode; then
		export DISABLE_QRCODE=1
		export DISABLE_QRPNG=1
	fi
	if use python; then
		export ENABLE_PYTHON=1
	fi
	#set install directory to /usr.
	sed -i -e "s,/usr/local,${EPREFIX}/usr,g" cfg/global_vars.mk || die "Failed to set install directory!"
}

src_install() {
	default
	if ! use sound; then
		rm -r "${ED}"/usr/share/${PN}/sounds || die "Could not remove sounds directory"
	fi
}
