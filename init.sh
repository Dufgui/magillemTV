#!/usr/bin/env bash -x

docker rm mds_smashing
rm -Rf smashing


docker run -d -p 8080:3030 --name mds_smashing rgcamus/alpine_smashing

SMASHING_HOST_PATH=`dirname "$0"`

cd $SMASHING_HOST_PATH
SMASHING_HOST_PATH=`pwd`
mkdir smashing
SMASHING_HOST_PATH="$SMASHING_HOST_PATH/smashing"

docker cp mds_smashing:/smashing/dashboards $SMASHING_HOST_PATH/
docker cp mds_smashing:/smashing/jobs $SMASHING_HOST_PATH/
docker cp mds_smashing:/smashing/widgets $SMASHING_HOST_PATH/
docker cp mds_smashing:/smashing/config $SMASHING_HOST_PATH/
docker cp mds_smashing:/smashing/public $SMASHING_HOST_PATH/

docker stop mds_smashing
docker rm mds_smashing

#echo "source 'https://rubygems.org'" >> $SMASHING_HOST_PATH/smashing/Gemfile
#echo "gem 'jira-ruby'" >> $SMASHING_HOST_PATH/smashing/Gemfile

docker run -p 8080:3030 -d \
-v=${SMASHING_HOST_PATH}/dashboards:/dashboards \
-v=${SMASHING_HOST_PATH}/jobs:/jobs \
-v=${SMASHING_HOST_PATH}/config:/config \
-v=${SMASHING_HOST_PATH}/public:/public \
-v=${SMASHING_HOST_PATH}/widgets:/widgets \
-e GEMS="thin jira-ruby" \
-e WIDGETS="1b4b99e449c628e77957c8a6d6bb5793 66d68345f2f89fa277ccdf74df1f91a7 a3ef8ae07a1fe1bb1d59a8f4c43f2190 52ad98eeddb851faff180136236645ad" \
--name mds_smashing \
 rgcamus/alpine_smashing

