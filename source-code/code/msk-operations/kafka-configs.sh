#!/bin/bash
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerString --output text)

# describe configs for broker 1
kafka-configs --bootstrap-server $KAFKA --entity-type brokers --entity-name 1 --describe

# alter configs for broker 1
kafka-configs --bootstrap-server $KAFKA --entity-type brokers --entity-name 1 --alter --add-config log.cleaner.threads=2

# cluster wide describe
kafka-configs --bootstrap-server $KAFKA --entity-type brokers --entity-default --describe

# cluster wide alter
kafka-configs --bootstrap-server $KAFKA --entity-type brokers --entity-default --alter --add-config log.cleaner.threads=2