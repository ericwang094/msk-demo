#!/bin/bash

export KAFKA_TLS=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:eu-west-1:648641612148:cluster/MSKClusterDemo/553bf759-45fa-4cea-b302-93493bd2a11b-2 --query BootstrapBrokerStringTls --output text)

# verify TLS certificate from AWS
openssl s_client -connect b-5.mskclusterdemo.9xca1s.c2.kafka.eu-west-1.amazonaws.com:9094

# information displayed differently
openssl s_client -connect b-5.mskclusterdemo.9xca1s.c2.kafka.eu-west-1.amazonaws.com:9094 2>/dev/null | openssl x509 -noout -text -certopt no_header,no_version,no_serial,no_signame,no_pubkey,no_sigdump,no_aux -subject -nameopt multiline -issuer


# try to create topic for the demo
kafka-topics --bootstrap-server $KAFKA_TLS --create --topic TLSTestTopic --partitions 3 --replication-factor 3

echo 'security.protocol=SSL' > client-ssl.properties


# create the topic correctly
kafka-topics --bootstrap-server $KAFKA_TLS --create --topic TLSTestTopic --partitions 3 --replication-factor 3 --command-config client-ssl.properties

# documentation reference:
# https://docs.aws.amazon.com/msk/latest/developerguide/msk-working-with-encryption.html

# Corretto 11
cp /usr/lib/jvm/java-11-amazon-corretto.x86_64/lib/security/cacerts /tmp/kafka.client.truststore.jks 

# Java JDK 8
cp /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /tmp/kafka.client.truststore.jks

# new property
echo 'ssl.truststore.location=/tmp/kafka.client.truststore.jks' >> client-ssl.properties

# producer
kafka-console-producer --broker-list $KAFKA_TLS --producer.config client-ssl.properties --topic TLSTestTopic
