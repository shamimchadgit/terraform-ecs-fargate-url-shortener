#!/bin/bash

yum update -y
yum install -y java-17-amazon-corretto awscli

# Mount EBS volume
mkfs.ext4 /dev/xvdf
mkdir -p /kafka-data
mount /dev/xvdf /kafka-data
chown -R ec2-user:ec2-user /kafka-data
echo "/dev/xvdf /kafka-data ext4 defaults,nofail 0 2" >> /etc/fstab

cd /opt

aws s3 cp s3://\${kafka_bucket}/kafka_2.13-4.2.0.tgz .

tar -xzf kafka_2.13-4.2.0.tgz
mv kafka_2.13-4.2.0 kafka
cd kafka

# KRaft
KAFKA_CLUSTER_ID=\$(bin/kafka-storage.sh random-uuid)
bin/kafka-storage.sh format -t \$KAFKA_CLUSTER_ID -c config/kraft/server.properties

PRIVATE_IP=\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "listeners=PLAINTEXT://0.0.0.0:9092" >> config/kraft/server.properties
echo "advertised.listeners=PLAINTEXT://\$PRIVATE_IP:9092" >> config/kraft/server.properties

bin/kafka-server-start.sh -daemon config/kraft/server.properties

# Topic
bin/kafka-topics.sh --create \
  --topic url-clicks \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1
