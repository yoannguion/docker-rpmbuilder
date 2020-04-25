#!/bin/bash
set -e "${VERBOSE:+-x}"

BUILD=true
if [[ $1 == --sh ]]; then
  BUILD=false
  shift
fi

SPEC="$1"
OUTDIR="${2:-$PWD}"
if [[ -z ${SPEC} || ! -e ${SPEC} ]]; then
  echo "Usage: docker run [--rm]" \
    "--volume=/path/to/source:/src --workdir=/src" \
    "rpmbuild [--sh] SPECFILE [OUTDIR=.]" >&2
  exit 2
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash "${VERBOSE:+-x}" -c "${PRE_BUILDDEP}"
fi

# install build dependencies declared in the specfile
yum-builddep -y "${SPEC}"

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec "${SHELL:-/bin/bash}" -l
fi

# execute the build as rpmbuild user
runuser rpmbuild /docker-rpm-build.sh "$@"

# copy the results back; done as root as rpmbuild most likely doesn't
# have permissions for OUTDIR; ensure ownership of output is consistent
# with source so that the caller of this image doesn't run into
# permission issues
mkdir -p "${OUTDIR}"
cp "${VERBOSE:+-v}" -a --reflink=auto \
  ~rpmbuild/rpmbuild/{RPMS,SRPMS} "${OUTDIR}/"
TO_CHOWN=( "${OUTDIR}/"{RPMS,SRPMS} )
if [[ ${OUTDIR} != ${PWD} ]]; then
  TO_CHOWN=( "${OUTDIR}" )
fi
chown "${VERBOSE:+-v}" -R --reference="${PWD}" "${TO_CHOWN[@]}"
