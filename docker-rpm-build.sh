#!/bin/bash
set -e "${VERBOSE:+-x}"

SPEC="${1:?}"
TOPDIR="${HOME}/rpmbuild"

# copy sources and spec into rpmbuild's work dir
cp "${VERBOSE:+-v}" -a --reflink=auto * "${TOPDIR}/SOURCES/"
cp "${VERBOSE:+-v}" -a --reflink=auto "${SPEC}" "${TOPDIR}/SPECS/"
SPEC="${TOPDIR}/SPECS/${SPEC##*/}"

# build the RPMs
/srpm-tool-get-sources ${SPEC} "${TOPDIR}/SOURCES/"
rpmbuild "${VERBOSE:+-v}" -ba "${SPEC}"
