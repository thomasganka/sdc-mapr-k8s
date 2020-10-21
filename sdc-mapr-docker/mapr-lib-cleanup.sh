#!/usr/bin/env bash

# This script is a workaround for https://issues.streamsets.com/browse/SDC-15986 if needed

cd $SDC_HOME/streamsets-libs/streamsets-datacollector-mapr_6_1-lib/lib

# rm xz-1.0.jar
# rm slf4j-api-1.7.10.jar
# rm slf4j-log4j12-1.7.10.jar
# rm commons-codec-1.4.jar
# rm jackson-annotations-2.9.5.jar
# rm jackson-core-2.9.5.jar
# rm jackson-databind-2.9.5.jar
# rm ojai-2.0-mapr-1710.jar
# rm commons-compress-1.19.jar
# rm hadoop-common-2.7.0.jar
# ln -s /opt/mapr/hadoop/hadoop-2.7.0/share/hadoop/common/hadoop-common-2.7.0-mapr-1808.jar hadoop-common-2.7.0-mapr-1808.jar
# rm jettison-1.1.jar
# rm guava-14.0.1.jar
# rm commons-lang-2.5.jar
# rm avro-1.7.6.jar
# rm javax.inject-1.jar
# rm xercesImpl-2.11.0.SP5.jar
# rm 'maprd-tools*.jar'
