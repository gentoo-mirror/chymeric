# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#CMAKE_MAKEFILE_GENERATOR="emake"
PYTHON_COMPAT=( python3_{10..11} )

inherit cmake distutils-r1 git-r3 ninja-utils
#inherit cmake-multilib distutils-r1 git-r3 ninja-utils
#inherit cmake distutils-r1 git-r3 multilib ninja-utils

GTS_HASH="962155a01f5a1b87bd64e3e3d880b4dbc2347ac7"
#NIFTI_HASH="65f801b9c2f1f15f4de4a19d45e6595c25765632"
NIFTI_HASH="da476fd27f46098f37f5c9c4c1baee01e559572c"
#GIFTI_HASH="5eae81ba1e87ef3553df3b6ba585f12dc81a0030"
GIFTI_HASH="d3e873d8539d9b469daf7db04093da1d7e73d4f7"

DESCRIPTION="Advanced Normalitazion Tools for neuroimaging"
HOMEPAGE="http://stnava.github.io/ANTs/"
SRC_URI="
	https://github.com/NIFTI-Imaging/nifti_clib/archive/${NIFTI_HASH}.tar.gz
	https://github.com/NIFTI-Imaging/gifti_clib/archive/${GIFTI_HASH}.tar.gz
	"
	#https://github.com/leej3/gts/archive/${GTS_HASH}.tar.gz
EGIT_REPO_URI="https://github.com/TheChymera/afni.git"
EGIT_BRANCH="packaging"

SLOT="0"
LICENSE="GPL-3+"
KEYWORDS=""
IUSE="test whirlgif"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libf2c
	dev-libs/expat
	dev-util/ninja
	media-libs/freeglut
	media-libs/glu
	media-libs/netpbm
	media-libs/qhull
	media-video/mpeg-tools
	sci-libs/gsl
	sci-libs/gts
	sys-devel/llvm:*
	sys-libs/libomp
	dev-libs/libpthread-stubs
	virtual/jpeg-compat:62
	x11-libs/libGLw
	x11-libs/libXft
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXpm
	x11-libs/libXt
	x11-libs/motif[-static-libs]
	"
DEPEND="
	${RDEPEND}
	app-shells/tcsh
	"
# Prospectively:
#Update jpeg-compat to virtual/jpeg:0
# look for xmhtlm

	#tar xf "${DISTDIR}/${GTS_HASH}.tar.gz" || die
src_prepare() {
	tar xf "${DISTDIR}/${NIFTI_HASH}.tar.gz" || die
	tar xf "${DISTDIR}/${GIFTI_HASH}.tar.gz" || die
	cmake_src_prepare
	default
	}

src_configure() {
	#LDFLAGS="-L${S}/${LIBDIR} ${LDFLAGS}" econf --enable-progpath="${EPREFIX}/usr/bin"
	if use !whirlgif; then
		eapply "${FILESDIR}/${PN}-whirlgif.patch"
	fi
	export CFLAGS="-pthread ${CFLAGS}"
	export GIT_REPO_VERSION=3.0.1.1
	#export DO_NOT_USE_PIP=true
	#export EXPLICIT_AFNIPY_INSTALL=false
	#export LDFLAGS="-lpthread ${LDFLAGS}"
	#-CC="$(tc-getCC)"
		#-DFETCHCONTENT_SOURCE_DIR_GTS="${WORKDIR}/${P}/gts-${GTS_HASH}"
		#-DUSE_SYSTEM_GTS=OFF
	local mycmakeargs=(
		-DLIBDIR=/usr/$(get_libdir)
		-DNIFTI_INSTALL_LIBRARY_DIR=/usr/$(get_libdir)
		-DGIFTI_INSTALL_LIBRARY_DIR=/usr/$(get_libdir)
		-DGIFTI_INSTALL_LIB_DIR=/usr/$(get_libdir)
		-DAFNI_INSTALL_LIBRARY_DIR=/usr/$(get_libdir)
		-DCMAKE_INSTALL_LIBDIR=/usr/$(get_libdir)
		-DCOMP_COREBINARIES=ON
		-DUSE_SYSTEM_NIFTI=OFF
		-DUSE_SYSTEM_GIFTI=OFF
		-DUSE_SYSTEM_XMHTML=OFF
		-DUSE_SYSTEM_GTS=ON
		-DFETCHCONTENT_SOURCE_DIR_NIFTI_CLIB="${WORKDIR}/${P}/nifti_clib-${NIFTI_HASH}"
		-DFETCHCONTENT_SOURCE_DIR_GIFTI_CLIB="${WORKDIR}/${P}/gifti_clib-${GIFTI_HASH}"
		-DCOMP_GUI=ON
		-DCOMP_PLUGINS=ON
		-DUSE_OMP=ON
		-DCOMP_PYTHON=OFF
		#-DCOMP_PYTHON=ON
		#-DSTANDARD_PYTHON_INSTALL=OFF
		#-DPython_FIND_VIRTUALENV=STANDARD
		#-DPython_FIND_STRATEGY=LOCATION
		-DUSE_SYSTEM_F2C=ON
	)
		#-DBUILD_SHARED_LIBS=OFF
	tc-export CC
	cmake_src_configure
	#python_foreach_impl cmake_src_configure
	#python_foreach_impl python_optimize
}

src_compile() {
	#python_foreach_impl cmake_src_compile
	cmake_src_compile
	pushd src/python_scripts
		distutils-r1_src_compile
	popd
	#cmake_src_compile
	#cd ../afni-9999_build
	#default
	#eninja || die
}

#/work/afni-9999/nifti_clib-65f801b9c2f1f15f4de4a19d45e6595c25765632

src_install() {
	#python_foreach_impl cmake_src_install
	#python_foreach_impl python_optimize
	cmake_src_install
	pushd src/python_scripts
		distutils-r1_src_install
	popd
	#cd ../afni-9999_build
	#DESTDIR=${D} eninja install
	# File collision, upstream confirmation here:
	# https://github.com/afni/afni/issues/558#issuecomment-1887693900
	cd ${D}
	#pwd
	#ls -lah
	#exit
	rm usr/bin/mpeg_encode
}
