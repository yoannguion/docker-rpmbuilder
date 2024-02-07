docker-rpmbuilder
=================

A minimal docker rpmbuilder image.

Based on centos, includes only rpmdevtools and yum-utils and a couple
of scripts that automate building RPM packages.

The scripts take care of installing build dependencies (using
yum-builddep), building the package (using rpmbuild) and placing the
resulting RPMs in output directory.

The setup is based on Fedora packaging how-to:
http://fedoraproject.org/wiki/How_to_create_an_RPM_package

Usage
=====

The image expects that work directory will be set to directory
containing the sources (mounted from the host).

Typical usage:

```sh
docker run --rm --volume=$PWD:/src --workdir=/src \
  yoannguion/rpmbuilder project.spec
```

This will build the project.spec file in current directory, placing
results in `RPMS/${ARCH}/` and `SRPMS/` subdirectories under current
directory.

You can also specify to place the results in a subdirectory:

```sh
docker run --rm --volume=$PWD:/src --workdir=/src \
  yoannguion/rpmbuilder project.spec OUTDIR
```

This will create `OUTDIR` if necessary and place the results in
`OUTDIR/RPMS/${ARCH}/` and `OUTDIR/SRPMS/`.

If your package requires something from a non-core repo to build, you
can add that repo using a PRE_BUILDDEP hook.  It is an env variable
that should contain an inline script or command to add the repo you
need.  E.g. for EPEL do:

```sh
docker run --rm --volume=$PWD:/src --workdir=/src \
  --env=PRE_BUILDDEP="yum install -y epel-release" \
  yoannguion/rpmbuilder project.spec
```


