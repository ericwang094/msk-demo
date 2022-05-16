```
export KAFKA=$(aws kafka get-bootstrap-brokers --cluster-arn arn:aws:kafka:ap-southeast-2:663493158590:cluster/MSKClusterDemo/4218d9df-08ab-4f76-92c1-2b0c2f3d4257-2 --query BootstrapBrokerString --output text)
```

```
kafka-console-consumer --bootstrap-server $KAFKA --topic topic1 --from-beginning
```

```
kafka-console-producer --bootstrap-server $KAFKA --topic topic1
```