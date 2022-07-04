from kafka import KafkaProducer, KafkaConsumer
import boto3
import logging as log
import sys

log.basicConfig(format='$(asctime)s $(name)-12s $(levelname)-8s $(message)s',
                datefmt="%Y-%m-%d %H:%M:%S",
                level=log.INFO)

def main(args):
    msk_cluster_arn = 'arn:aws:kafka:ap-southeast-2:663493158590:cluster/MSKClusterDemo/c6916ce1-be46-4f19-9c73-adc9040c3b0a-2'
    topic = "topic1"

    try:
        msk = boto3.client("kafka", region_name="ap-southeast-2")
        response = msk.get_bootstrap_brokers(ClusterArn=msk_cluster_arn)
        bootstrap_server = response['BootstrapBrokerString']

        consumer = KafkaConsumer(bootstrap_servers=bootstrap_server)
        consumer.subscribe([topic])
        for msg in consumer:
            log.info("consumer record: \n{}".format(msg))
    except Exception as ex:
        pass

if __name__ == "__main__":
    main(sys.argv)