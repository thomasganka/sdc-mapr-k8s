# Copyright 2017 StreamSets Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04
LABEL maintainer="Mark Brooks <mark@streamsets.com>"

ARG SDC_VERSION=3.18.1
ARG SDC_TARBALL=streamsets-datacollector-core-3.18.1.tgz
ARG SDC_URL=https://s3-us-west-2.amazonaws.com/nightly.streamsets.com/datacollector/3.18/3.18.1/tarball/${SDC_TARBALL}

RUN apt-get -y update
RUN apt-get -y install curl
RUN apt-get -y install sudo

# Install Java
RUN apt-get -y install openjdk-8-jdk

RUN groupadd mapr

# MapR Client Packages
ARG MAPR_LIBRDKAFKA_PKG=mapr-librdkafka_0.11.3.201803231414_all.deb
ARG MAPR_CLIENT_PKG=mapr-client-6.1.0.20180926230239.GA-1.amd64.deb
ARG MAPR_MEP6_KAFKA_PKG=mapr-kafka_1.1.1.201901241010_all.deb

# Install MapR Client
RUN curl -o /tmp/${MAPR_LIBRDKAFKA_PKG} -L http://archive.mapr.com/releases/v6.1.0/ubuntu/${MAPR_LIBRDKAFKA_PKG}
RUN curl -o /tmp/${MAPR_CLIENT_PKG} -L http://archive.mapr.com/releases/v6.1.0/ubuntu/${MAPR_CLIENT_PKG}
RUN curl -o /tmp/${MAPR_MEP6_KAFKA_PKG} -L http://archive.mapr.com/releases/MEP/MEP-6.1/ubuntu/${MAPR_MEP6_KAFKA_PKG}
RUN apt-get -y install /tmp/${MAPR_LIBRDKAFKA_PKG}
RUN apt-get -y install /tmp/${MAPR_CLIENT_PKG}
RUN apt-get -y install /tmp/${MAPR_MEP6_KAFKA_PKG}
RUN rm -f /tmp/mapr-*

# We set a UID/GID for the SDC user because certain test environments require these to be consistent throughout
# the cluster. We use 20159 because it's above the default value of YARN's min.user.id property.
ARG SDC_UID=20159
ARG SDC_GID=20159

RUN echo '*                hard    nofile          70000' >> /etc/security/limits.conf
RUN echo '*                soft    nofile          70000' >> /etc/security/limits.conf

# Begin Data Collector installation

ARG SDC_USER=sdc
ARG SDC_HOME="/opt/streamsets-datacollector-${SDC_VERSION}"

# The paths below should generally be attached to a VOLUME for persistence.
# SDC_CONF is where configuration files are stored. This can be shared.
# SDC_DATA is a volume for storing collector state. Do not share this between containers.
# SDC_LOG is an optional volume for file based logs.
# SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
# STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
# USER_LIBRARIES_DIR is where custom stage libraries are installed.
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/data \
    SDC_DIST=${SDC_HOME} \
    SDC_HOME=${SDC_HOME} \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources \
    USER_LIBRARIES_DIR=/opt/streamsets-datacollector-user-libs
ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"

ENV SDC_JAVA_OPTS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-i8 -Dmaprlogin.password.enabled=true ${SDC_JAVA_OPTS}"

# Run the SDC configuration script.
COPY sdc-configure.sh *.tgz /tmp/
RUN /tmp/sdc-configure.sh

# Copy files in $PROJECT_ROOT/resources dir to the SDC_RESOURCES dir.
COPY resources/ ${SDC_RESOURCES}/
RUN chown -R sdc:sdc ${SDC_RESOURCES}/

# Copy local "sdc-extras" libs to STREAMSETS_LIBRARIES_EXTRA_DIR.
# Local files should be placed in appropriate stage lib subdirectories.  For example
# to add a JDBC driver like my-jdbc.jar to the JDBC stage lib, the local file my-jdbc.jar
# should be at the location $PROJECT_ROOT/sdc-extras/streamsets-datacollector-jdbc-lib/lib/my-jdbc.jar
COPY sdc-extras/ ${STREAMSETS_LIBRARIES_EXTRA_DIR}/
RUN chown -R sdc:sdc ${STREAMSETS_LIBRARIES_EXTRA_DIR}/

# Copy the stage libs and enterprise stage libs
COPY --chown=sdc:sdc streamsets-libs ${SDC_DIST}/streamsets-libs

# Run setup-mapr script
ENV MAPR_HOME=/opt/mapr
ENV MAPR_VERSION=6.1.0
ENV MAPR_MEP_VERSION=6
RUN ${SDC_HOME}/bin/streamsets setup-mapr

# Workaround for https://issues.streamsets.com/browse/SDC-15986
COPY mapr-lib-cleanup.sh /tmp
RUN /tmp/mapr-lib-cleanup.sh

USER ${SDC_USER}
EXPOSE 18630
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]
