from kafka import KafkaProducer
import boto3
import logging as log
import sys

log.basicConfig(format='$(asctime)s $(name)-12s $(levelname)-8s $(message)s',
                datefmt="%Y-%m-%d %H:%M:%S",
                level=log.INFO)

def main(args):
    msk_cluster_arn = 'arn:aws:kafka:ap-southeast-2:663493158590:cluster/MSKClusterDemo/4218d9df-08ab-4f76-92c1-2b0c2f3d4257-2'
    topic = "topic1"
    message = "hello-from-msk-client"

    try:
        msk = boto3.client("kafka", region_name="ap-southeast-2")
        response = msk.get_bootstrap_brokers(ClusterArn=msk_cluster_arn)
        bootstrap_server = response['BootstrapBrokerString']

        producer = KafkaProducer(bootstrap_servers=bootstrap_server)
        message_bytes = bytes(message, encoding='utf-8')
        producer.send(topic, value=message_bytes)
        producer.flush()
        log.info("msk message send successfully")
    except Exception as ex:
        pass

if __name__ == "__main__":
    main(sys.argv)