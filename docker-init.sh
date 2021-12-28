#!/bin/bash
set -e
BUILD=true
if [[ $1 == --sh ]]; then
  BUILD=false
  shift
fi

if [ ! -z "$SPEC_FILE" ]; then
  SPEC=$SPEC_FILE
else
  SPEC="$1"
fi

if [ -z "$OUTDIR" ]; then
  OUTDIR="${2:-$PWD}"
fi

if [[ -z ${SPEC} || ! -e ${SPEC} ]]; then
  echo "Usage: docker run [--rm]" \
    "--volume=/path/to/source:/src --workdir=/src" \
    "rpmbuild [--sh] SPECFILE [OUTDIR=.]" >&2
  exit 2
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash -c "${PRE_BUILDDEP}"
fi

# install build dependencies declared in the specfile
yum-builddep -y "${SPEC}"

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec "${SHELL:-/bin/bash}" -l
fi

if [[ -n ${UID_BUILDER} ]]; then
  echo "change rpmbuild uid to ${UID_BUILDER}"
  usermod -u ${UID_BUILDER} rpmbuild
fi

if [[ -n ${GID_BUILDER} ]]; then
  echo "change rpmbuild gid to ${GID_BUILDER}"
  groupmod  -g ${GID_BUILDER} rpmbuild
fi

chown rpmbuild: -R /home/rpmbuild

# execute the build as rpmbuild user
runuser rpmbuild /docker-rpm-build.sh "${SPEC}"
if [[ -n ${UID_BUILDER} ]]; then
  runuser rpmbuild /release.sh
else
  /release.sh
fi