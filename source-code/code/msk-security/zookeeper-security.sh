#!/bin/bash

aws kafka list-clusters --query 'ClusterInfoList[*].[ClusterName, ZookeeperConnectString]'