#!/bin/bash
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerString --output text)


# create input and output topics
kafka-topics --bootstrap-server $KAFKA --create --replication-factor 3 --partitions 3 --topic streams-plaintext-input 
kafka-topics --bootstrap-server $KAFKA --create --replication-factor 3 --partitions 3 --topic streams-wordcount-output

# start a Kafka console consumer
kafka-console-consumer --bootstrap-server $KAFKA \
    --topic streams-wordcount-output \
    --value-deserializer org.apache.kafka.common.serialization.LongDeserializer \
    --property print.key=true  \
    --property key.separator=" " 

# start a Kafka console producer
kafka-console-producer --bootstrap-server $KAFKA --topic streams-plaintext-input 