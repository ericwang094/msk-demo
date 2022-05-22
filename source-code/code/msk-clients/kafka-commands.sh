#!/bin/bash

# AWS CLI calls
aws kafka list-clusters 

aws kafka describe-cluster --cluster-arn <cluster-arn>

aws kafka describe-cluster --cluster-arn <cluster-arn>  
    --query 'ClusterInfo.ZookeeperConnectString'

aws kafka get-bootstrap-brokers --cluster-arn <cluster-arn>


# Create topics
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerString --output text)
kafka-topics --bootstrap-server $KAFKA --list
kafka-topics --bootstrap-server $KAFKA --create --replication-factor 3 --partitions 3 --topic topic1

# Produce / Consume
kafka-console-consumer --bootstrap-server $KAFKA --topic topic1 --from-beginning
kafka-console-producer --bootstrap-server $KAFKA --topic topic1

# Zookeeper shell
# Get the Zookeeper Connect String
aws kafka list-clusters \
  --query 'ClusterInfoList[*].[ClusterName, ClusterArn, ZookeeperConnectString]'

# Use the Zookeeper Connect String in the next command
zookeeper-shell <zookeeper-connect-string>

# Once in the zookeeper shell
ls /brokers/topics