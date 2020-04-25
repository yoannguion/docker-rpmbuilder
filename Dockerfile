FROM centos:8
MAINTAINER yoannguion <yoannguion@gmail.com>
LABEL "maintainer"="Yoann Guion <yoannguion@gmail.com>"
LABEL "com.github.actions.name"="RPM Builder"
LABEL "com.github.actions.description"="Build RPM on centos 8"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="green"

RUN yum -y --setopt="tsflags=nodocs" update && \
    yum -y --setopt="tsflags=nodocs" install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum install -y rpmdevtools yum-utils wget rpm-sign expect && \
    yum clean all && \
    rm -rf /var/cache/*

ADD docker-init.sh docker-rpm-build.sh srpm-tool-get-sources /
RUN chmod +x /*.sh /srpm-tool-get-sources

RUN useradd rpmbuild
USER rpmbuild
RUN rpmdev-setuptree
USER root

CMD ["/docker-init.sh"]
