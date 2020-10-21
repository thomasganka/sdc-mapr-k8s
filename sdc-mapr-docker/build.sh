#!/usr/bin/env bash

# This script builds a custom Docker image of StreamSets Data Collector
# on Ubuntu 16.04 with MapR client support.  

# Image Name
IMAGE_NAME=<YOUR IMAGE NAME>

# SDC Version
SDC_VERSION=3.18.1

# Base SDC URL 
BASE_SDC_URL=https://s3-us-west-2.amazonaws.com/nightly.streamsets.com/datacollector/3.18/3.18.1/tarball

# Base Enterprise Stage Lib URL 
BASE_ESL_URL=http://archives.streamsets.com/datacollector/latest/tarball/enterprise

# A space separated list of stage libs to include in the image
# Make sure to always include these two MapR stage libs:
#  streamsets-datacollector-mapr_6_1-lib
#  streamsets-datacollector-mapr_6_1-mep6-lib
SDC_STAGE_LIBS="streamsets-datacollector-mapr_6_1-lib streamsets-datacollector-mapr_6_1-mep6-lib streamsets-datacollector-jython_2_7-lib"

# A space separated list of enterprise stage libs to download
SDC_ENTERPRISE_STAGE_LIBS="streamsets-datacollector-snowflake-lib-1.5.0"

# Use a tmp directory to unpack the downloaded stage libs
mkdir -p tmp-stage-libs
cd tmp-stage-libs

# Download and extract stage libs
for s in $SDC_STAGE_LIBS; 
do 
  wget ${BASE_SDC_URL}/${s}-${SDC_VERSION}.tgz; 
  tar -xvf ${s}-${SDC_VERSION}.tgz;
  rm ${s}-${SDC_VERSION}.tgz;
done

# Download and extract enterprise stage libs
cd streamsets-datacollector-${SDC_VERSION}
for s in $SDC_ENTERPRISE_STAGE_LIBS; 
do 
  wget ${BASE_ESL_URL}/${s}.tgz; 
  tar -xvf ${s}.tgz; 
  rm -rf ${s}.tgz;
done

cd ../..

mv tmp-stage-libs/streamsets-datacollector-${SDC_VERSION}/streamsets-libs .

# remove tmp dir
rm -rf tmp-stage-libs

# Build the image
docker build -t $IMAGE_NAME .

# clean up 
rm -rf streamsets-libs

# Push the image
docker push $IMAGE_NAME

