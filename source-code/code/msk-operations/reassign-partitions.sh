#!/bin/bash

export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerString --output text)

# Specify list of topics to move
cat <<EOT > topics-to-move.json
{"topics": [{"topic": "__consumer_offsets"},
            {"topic": "_schemas"},
            {"topic": "customer-avro"},
            {"topic": "from-ahkq"},
            {"topic": "topic1"}],
"version":1
}
EOT

export ZOOKEEPER=$(aws kafka describe-cluster --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query 'ClusterInfo.ZookeeperConnectString' --output text)

# generate reassignment and save the output to reassignment.json
kafka-reassign-partitions --bootstrap-server $KAFKA --topics-to-move-json-file topics-to-move.json --broker-list "1,2,3,4,5,6" --generate --zookeeper $ZOOKEEPER

# execute the reassignment with throttle (optional)
kafka-reassign-partitions --bootstrap-server $KAFKA --reassignment-json-file  reassignment.json --execute --throttle 50000000 --zookeeper $ZOOKEEPER

# verify the reassignment
kafka-reassign-partitions --bootstrap-server $KAFKA --reassignment-json-file  reassignment.json --verify --zookeeper $ZOOKEEPER