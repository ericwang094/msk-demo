```
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:ap-southeast-2:663493158590:cluster/MSKClusterDemo/c6916ce1-be46-4f19-9c73-adc9040c3b0a-2 --query BootstrapBrokerString --output text)
```

```
kafka-console-consumer --bootstrap-server $KAFKA --topic topic1 --from-beginning
```

```
kafka-console-producer --bootstrap-server $KAFKA --topic topic1
```


* Create topic1

```
kafka-topics --bootstrap-server $MSK_KAFKA --create --replication-factor 3 --partitions 3 --topic topic1
```