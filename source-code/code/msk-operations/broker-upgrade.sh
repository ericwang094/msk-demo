#!/bin/bash
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerString --output text)

# Producer
for x in {1..10000}; do echo $x; sleep 1; done | kafka-console-producer --bootstrap-server $KAFKA --topic topic1 

# Consumer
kafka-console-consumer --bootstrap-server $KAFKA --topic topic1