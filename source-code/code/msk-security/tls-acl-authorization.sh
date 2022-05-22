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


# Grant Read Access from a random user
kafka-acls --authorizer-properties zookeeper.connect=$ZOOKEEPER \
    --add --allow-principal "User:CN=NOT-A-USER" \
    --operation Read \
    --group=* \
    --topic secure-topic 

# Topic authorization failure
kafka-console-consumer --bootstrap-server $KAFKA_TLS --topic secure-topic --consumer.config client-ssl-auth.properties --from-beginning 

DNAME=Kafka-Toolbox

# Add proper authorization
kafka-acls --authorizer-properties zookeeper.connect=$ZOOKEEPER \
    --add --allow-principal "User:CN=$DNAME" \
    --operation Read \
    --group=* \
    --topic secure-topic 

# working!
kafka-console-consumer --bootstrap-server $KAFKA_TLS --topic secure-topic --consumer.config client-ssl-auth.properties --from-beginning 

# Add write authorization
kafka-acls --authorizer-properties zookeeper.connect=$ZOOKEEPER \
    --add --allow-principal "User:CN=$DNAME" \
    --operation Write \
    --topic secure-topic 

# Produce
kafka-console-producer --bootstrap-server $KAFKA_TLS --topic secure-topic --producer.config client-ssl-auth.properties