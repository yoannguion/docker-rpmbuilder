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
FULL_NAME=$(cat ${GITHUB_EVENT_PATH} | jq -r .repository.full_name)
echo $FULL_NAME
REPO_URL="https://api.github.com/repos/$FULL_NAME"
echo $REPO_URL
# prepare upload URL
if [ -z $RELEASE_TAG ]; then

  LATEST_RELEASE_URL="$REPO_URL/releases/latest"
else
        nb_good_tab=`curl -H "Authorization: Bearer ${RELEASE_GITHUB_TOKEN}" "$REPO_URL/tags" | grep -F "$RELEASE_TAG" | wc -l`
        if [ "$nb_good_tab" == "0" ]; then
                echo "should create tag"
                json="{\"tag_name\": \"$RELEASE_TAG\", \"name\": \"$RELEASE_TAG\"}"
                echo "$json"
                curl -X POST -H "Authorization: Bearer ${RELEASE_GITHUB_TOKEN}" -H "Content-Type: application/json" -d "$json" "$REPO_URL/releases"
        else
                echo "tag $RELEASE_TAG already exist"
        fi
    LATEST_RELEASE_URL="$REPO_URL/releases/tags/$RELEASE_TAG"
fi
echo $LATEST_RELEASE_URL;
RELEASE_ASSETS_UPLOAD_URL=$(curl -H "Authorization: Bearer ${RELEASE_GITHUB_TOKEN}" $LATEST_RELEASE_URL | jq -r .upload_url)
RELEASE_ASSETS_UPLOAD_URL=${RELEASE_ASSETS_UPLOAD_URL%\{?name,label\}}
echo "release url $RELEASE_ASSETS_UPLOAD_URL"

for i in $(find /home/rpmbuild/rpmbuild/SRPMS/ -name *.src.rpm); do
  uploadToGitHub $i
done

for i in $(find /home/rpmbuild/rpmbuild/RPMS/ -name *.rpm); do
  file=`basename $i`
  if [[ $file != *"debug"* ]]; then
    uploadToGitHub $i
  fi
done



