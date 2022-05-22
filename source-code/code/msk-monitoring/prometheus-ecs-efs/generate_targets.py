#!/usr/bin/python3

import boto3
import json
import logging as log
import os
import pprint
import sys

log.basicConfig(format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S',
                level=log.INFO)

pp = pprint.PrettyPrinter(indent=4)

def main(args):

    MANDATORY_ENV_VARS = ["REGION", "CLUSTER_ARN"]
    for var in MANDATORY_ENV_VARS:
        if var not in os.environ:
            raise EnvironmentError("Failed because {} is not set.".format(var))
    
    msk_cluster_arn = os.environ['CLUSTER_ARN']
    region = os.environ['REGION']
    
    jmx_targets = []
    node_targets = []
    try:
        # Get the list of nodes using MSK api
        client = boto3.client('kafka', region_name = region)
        list_nodes_response = client.list_nodes(ClusterArn = msk_cluster_arn)
        # pp.pprint(list_nodes_response['NodeInfoList'])

        for i in list_nodes_response['NodeInfoList']:
            jmx_targets.append(i['BrokerNodeInfo']['Endpoints'][0] + ":11001")
            node_targets.append(i['BrokerNodeInfo']['Endpoints'][0] + ":11002")

        print(jmx_targets)
    
        jmx_job = {'labels': {'job': 'jmx'}, 'targets': jmx_targets}
        node_job = {'labels': {'job': 'jmx'}, 'targets': node_targets}
        targets_json_content = [jmx_job, node_job]

        with open('/etc/prometheus/targets.json', 'w') as file:
            file.write(json.dumps(targets_json_content))

    except Exception as ex:
        log.error(str(ex))

if __name__ == "__main__":
    main(sys.argv)