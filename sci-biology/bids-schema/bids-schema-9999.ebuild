# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="YAML schema reference for BIDS specification"
HOMEPAGE="https://github.com/bids-standard/bids-schema"
EGIT_REPO_URI="https://github.com/bids-standard/bids-schema.git"

LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS=""

RDEPEND=""
DEPEND=""

src_install() {
	insinto "/usr/share/${PN}"
	doins -r versions/*
}
