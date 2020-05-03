FROM centos:7
MAINTAINER yoannguion <yoannguion@gmail.com>
LABEL "maintainer"="Yoann Guion <yoannguion@gmail.com>"
LABEL "com.github.actions.name"="RPM Builder"
LABEL "com.github.actions.description"="Build RPM on centos 7"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="green"

RUN yum -y --setopt="tsflags=nodocs" update && \
    yum -y --setopt="tsflags=nodocs" install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y rpmdevtools yum-utils wget rpm-sign expect jq && \
    yum-config-manager --enable extras && \
    yum group install -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/*

ADD docker-init.sh docker-rpm-build.sh srpm-tool-get-sources release.sh /
RUN chmod +x /*.sh /srpm-tool-get-sources

RUN useradd rpmbuild
USER rpmbuild
RUN rpmdev-setuptree
USER root

CMD ["/docker-init.sh"]
