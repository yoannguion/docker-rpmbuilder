#!/bin/bash
set -e
SPEC="$1"
TOPDIR="/home/rpmbuild/rpmbuild"

# copy sources and spec into rpmbuild's work dir
cp -a --reflink=auto * "${TOPDIR}/SOURCES/"
cp -a --reflink=auto "${SPEC}" "${TOPDIR}/SPECS/"

# build the RPMs
/srpm-tool-get-sources "${TOPDIR}/SPECS/${SPEC}" "${TOPDIR}/SOURCES/"
rpmbuild -ba "${TOPDIR}/SPECS/${SPEC}"
echo "rpmbuild finish so now publish releases"
/release.sh