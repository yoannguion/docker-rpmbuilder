#!/bin/bash
echo "copying RPMS/SRPMS ..."
find /home/rpmbuild/rpmbuild/ -type f | grep -i rpm$ | grep -v debug | xargs -i cp {} .
