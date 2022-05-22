#!/bin/bash

# download and extract prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.19.2/prometheus-2.19.2.linux-amd64.tar.gz
tar -xvzf prometheus-2.19.2.linux-amd64.tar.gz
cd prometheus-2.19.2.linux-amd64/

export CLUSTER_ARN=arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2


# edit prometheus.yml
# get kafka nodes & edit targets.json
aws kafka list-nodes --cluster-arn $CLUSTER_ARN \
    --query NodeInfoList[*].BrokerNodeInfo.Endpoints[]

# start prometheus
./prometheus