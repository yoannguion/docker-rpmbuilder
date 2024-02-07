FROM almalinux:9
MAINTAINER yoannguion <yoannguion@gmail.com>
LABEL "maintainer"="Yoann Guion <yoannguion@gmail.com>"
LABEL "com.github.actions.name"="RPM Builder"
LABEL "com.github.actions.description"="Build RPM on almalinux 9"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="green"

RUN yum -y --setopt="tsflags=nodocs" update && \
    yum -y --setopt="tsflags=nodocs" install epel-release && \
    yum install -y rpmdevtools yum-utils wget rpm-sign expect jq && \
    dnf config-manager --set-enabled extras && \
    dnf config-manager --set-enabled crb && \
    dnf group install -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/*

ADD docker-init.sh docker-rpm-build.sh srpm-tool-get-sources release.sh /
RUN chmod +x /*.sh /srpm-tool-get-sources

ENV QA_RPATHS=
ENV UID_BUILDER=
ENV GID_BUILDER=
RUN printf "=== UID[%s] / GID[%s]\n" "${UID_BUILDER}" "${GID_BUILDER}"; set -xe \
  ; if [ -n "${GID_BUILDER}" ] \
  ; then getent group "${GID_BUILDER}" >/dev/null 2>&1 || groupadd --gid "${GID_BUILDER}" --non-unique "rpmbuild" \
  ; fi \
  ; if [ -n "${UID_BUILDER}" ] \
  ; then CUR_BUILDER="$(id -n -u "${UID_BUILDER}" 2>/dev/null || true)" \
  ;   if [ -z "${CUR_BUILDER}" ] \
  ;   then OPT_GROUP="--user-group"; [ -n "${GID_BUILDER}" ] && OPT_GROUP="--gid ${GID_BUILDER}" \
  ;     useradd --non-unique --comment "RPM builder user" \
                --uid ${UID_BUILDER} ${OPT_GROUP} --groups "users" \
                --home "/home/rpmbuild" --create-home \
                --shell "/bin/bash" "rpmbuild" \
  ;   else OPT_GROUP=""; [ -n "${GID_BUILDER}" ] && OPT_GROUP="${GID_BUILDER}," \
  ;     usermod --append --groups "${OPT_GROUP}users" \
                --shell "/bin/bash" "${CUR_BUILDER}" \
  ;   fi \
  ;   DIR_BUILDER="$(getent passwd "${UID_BUILDER}" 2>/dev/null | cut -d: -f6)" \
  ;   if [ -n "${DIR_BUILDER}" -a -d "${DIR_BUILDER}" ] \
  ;     then echo ". /etc/profile"                       >> "${DIR_BUILDER}/.bashrc" \
  ;     [ -n "${GID_BUILDER}" ] && echo "umask 0002"     >> "${DIR_BUILDER}/.bashrc" \
  ;     [ -d "${DIR_BUILDER}/rpmbuild" ] || mkdir -p        "${DIR_BUILDER}/rpmbuild" \
  ;     chown "${UID_BUILDER}"                           -R "${DIR_BUILDER}" \
  ;   fi \
  ; else useradd rpmbuild \
  ; fi


USER rpmbuild
RUN rpmdev-setuptree
USER root

CMD ["/docker-init.sh"]
