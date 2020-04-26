#!/bin/bash
set -e "${VERBOSE:+-x}"

SPEC="${1:?}"
TOPDIR="/home/rpmbuild/rpmbuild"

# copy sources and spec into rpmbuild's work dir
cp "${VERBOSE:+-v}" -a --reflink=auto * "${TOPDIR}/SOURCES/"
cp "${VERBOSE:+-v}" -a --reflink=auto "${SPEC}" "${TOPDIR}/SPECS/"

# build the RPMs
/srpm-tool-get-sources ${TOPDIR}/SPECS/${SPEC}" "${TOPDIR}/SOURCES/"
rpmbuild "${VERBOSE:+-v}" -ba "${TOPDIR}/SPECS/${SPEC}"
