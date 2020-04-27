#!/bin/bash
uploadToGitHub () {
echo $1
file=`basename $1`
echo $file
curl \
  --fail \
  -X POST \
  --data-binary @$1 \
  -H 'Content-Type: application/octet-stream' \
  -H "Authorization: Bearer ${RELEASE_GITHUB_TOKEN}" \
  "${RELEASE_ASSETS_UPLOAD_URL}?name=$file"
return $?
}


cat ${GITHUB_EVENT_PATH}

# prepare upload URL
RELEASE_ASSETS_UPLOAD_URL=$(cat ${GITHUB_EVENT_PATH} | jq -r .release.upload_url)
RELEASE_ASSETS_UPLOAD_URL=${RELEASE_ASSETS_UPLOAD_URL%\{?name,label\}}
echo "release url $RELEASE_ASSETS_UPLOAD_URL"



for i in $(find /home/rpmbuild/rpmbuild/SRPMS/ -name *.src.rpm); do
  uploadToGitHub $i
done

for i in $(find /home/rpmbuild/rpmbuild/RPMS/x86_64/ -name *.rpm); do
  file=`basename $i`
  if [[ $file != *"debug"* ]]; then
    uploadToGitHub $i
  fi
done



