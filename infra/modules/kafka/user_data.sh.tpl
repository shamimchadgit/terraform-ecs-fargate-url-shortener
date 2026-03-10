#!/bin/bash

yum update -y 
yum install -y java-17-amazon-corretto awscli

cd /opt #store kafka in /opt (optional software installs in linux)

aws s3 cp s3://${kafka_bucket}/kafka_2.13-4.2.0.tgz .

tar -xzf kafka_2.13-4.2.0.tgz
mv kafka_2.13-4.2.0 kafka
cd kafka 

#KRaft

KAFKA_CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)

bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "listeners=PLAINTEXT://0.0.0.0:9092" >> config/kraft/server.properties

echo "advertised.listeners=PLAINTEXT://$PRIVATE_IP:9092" >> config/kraft/server.properties

bin/kafka-server-start.sh -daemon config/kraft/server.properties

# Topic (so app doesn't fail on first event)

bin/kafka-topics.sh --create \
  --topic url-clicks \
  --bootstrap-server localhost:9092 \
  --paritions 1 \
  --replication-factor 1
