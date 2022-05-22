#!/bin/bash

# Get the cluster ARN
aws kafka list-clusters --query 'ClusterInfoList[*].[ClusterName, ClusterArn, CurrentVersion]'

# export CLUSTER_ARN
export CLUSTER_ARN=arn:aws:kafka:eu-west-1:648641612148:cluster/demo-msk-auth/82e62ac0-6aad-4f71-b4c7-2bc856003952-2

# export KAFKA TLS endpoint 
export KAFKA_TLS=$(aws kafka get-bootstrap-brokers --cluster-arn $CLUSTER_ARN \
    --query BootstrapBrokerStringTls --output text)

echo $KAFKA_TLS

# export zookeeper connect string
export ZOOKEEPER=$(aws kafka describe-cluster --cluster-arn $CLUSTER_ARN \
    --query ClusterInfo.ZookeeperConnectString --output text)

echo $ZOOKEEPER

# on the client machine, create a client trust store
cp /usr/lib/jvm/java-11-amazon-corretto.x86_64/lib/security/cacerts /tmp/kafka.client.truststore.jks 

# create a certificate keystore for your kafka client
# change passwords as necessary
STOREPASS=Your-Store-Pass
ALIAS=Kafka-Toolbox-Client-Alias
DNAME=Kafka-Toolbox
keytool -genkey -keystore kafka.client.keystore.jks -validity 300 \
    -storepass $STOREPASS \
    -keypass $STOREPASS \
    -dname "CN=$DNAME" \
    -alias $ALIAS \
    -storetype pkcs12

# create a certificate signing request (CSR)
keytool -keystore kafka.client.keystore.jks -certreq \
    -file client-cert-sign-request \
    -alias $ALIAS \
    -storepass $STOREPASS \
    -keypass $STOREPASS

# inspect the content of the signing certificate request
cat client-cert-sign-request

# if it starts with -----BEGIN NEW CERTIFICATE REQUEST-----
# delete the word NEW (and the single space that follows it) from the beginning and the end of the file
sed -i -e "s/NEW //g" client-cert-sign-request


PRIVATE_CA_ARN=arn:aws:acm-pca:eu-west-1:648641612148:certificate-authority/cf1d807d-7289-4727-80d9-7122f92eda53

# sign the certificate
aws acm-pca issue-certificate \
    --certificate-authority-arn $PRIVATE_CA_ARN \
    --csr file://client-cert-sign-request \
    --signing-algorithm "SHA256WITHRSA" \
    --validity Value=300,Type="DAYS"

CERTIFICATE_ARN=arn:aws:acm-pca:eu-west-1:648641612148:certificate-authority/cf1d807d-7289-4727-80d9-7122f92eda53/certificate/255af51ee0db338d0fd2a70963e1e08b

# download the signed certificate
aws acm-pca get-certificate \
    --certificate-authority-arn $PRIVATE_CA_ARN \
    --certificate-arn $CERTIFICATE_ARN

# From the JSON result of running the previous command, copy the strings associated with Certificate and CertificateChain. Paste these two strings in a new file named signed-certificate-from-acm. Paste the string associated with Certificate first, followed by the string associated with CertificateChain. Replace the \n characters with new lines. The following is the structure of the file after you paste the certificate and certificate chain in it.

# trick to do it faster

# add the certificate
aws acm-pca get-certificate     --certificate-authority-arn $PRIVATE_CA_ARN     --certificate-arn $CERTIFICATE_ARN --query Certificate --output text > signed-certificate-from-acm

# append the certificate chain
aws acm-pca get-certificate     --certificate-authority-arn $PRIVATE_CA_ARN     --certificate-arn $CERTIFICATE_ARN --query CertificateChain --output text >> signed-certificate-from-acm

# add the certificate to the keystore
keytool -keystore kafka.client.keystore.jks -import \
    -file signed-certificate-from-acm \
    -alias $ALIAS \
    -storepass $STOREPASS \
    -keypass $STOREPASS


# create a file 
cat <<EOF > client-ssl-auth.properties
security.protocol=SSL
ssl.truststore.location=/tmp/kafka.client.truststore.jks
ssl.keystore.location=/home/ec2-user/kafka.client.keystore.jks
ssl.keystore.password=$STOREPASS
ssl.key.password=$STOREPASS
EOF

# create a Kafka topic
kafka-topics --zookeeper $ZOOKEEPER --create --replication-factor 2 --partitions 3 --topic secure-topic 

# this is working thanks to allow.everyone.if.no.acl.found=true

# produce to it
kafka-console-producer --bootstrap-server $KAFKA_TLS --topic secure-topic --producer.config client-ssl-auth.properties

# consume from it 
kafka-console-consumer --bootstrap-server $KAFKA_TLS --topic secure-topic --consumer.config client-ssl-auth.properties --from-beginning 

# not working without authentication
kafka-console-consumer --bootstrap-server $KAFKA_TLS --topic secure-topic --consumer.config client-ssl.properties --from-beginning 
