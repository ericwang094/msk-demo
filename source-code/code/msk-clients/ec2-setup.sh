#!/bin/bash
sudo su
yum update -y
yum install -y java-11-amazon-corretto-headless
sudo alternatives --config java
yum install -y python3 git jq maven nc
wget https://archive.apache.org/dist/kafka/2.5.0/kafka_2.13-2.5.0.tgz
tar -xzf kafka_2.13-2.5.0.tgz
mv kafka_2.13-2.5.0 /usr/local/
for i in /usr/local/kafka_2.13-2.5.0/bin/*.sh; do
	mv $i ${i%???}
done;
ln -sfn /usr/local/kafka_2.13-2.5.0 /usr/local/kafka
exit
echo 'export PATH=/usr/local/kafka/bin:$PATH' >> /home/ec2-user/.bashrc

aws configure 
# set region eu-west-1

sudo su
cp /usr/local/kafka_2.13-2.5.0/bin/kafka-run-class /usr/local/kafka_2.13-2.5.0/bin/kafka-run-class.sh 