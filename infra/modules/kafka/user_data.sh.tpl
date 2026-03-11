#!/bin/bash

# Update OS and install dependencies
yum update -y
yum install -y java-17-amazon-corretto awscli jq


# Detect and mount EBS volume
#device name AWS sees in Terraform may be different in Linux if NVMe-backed so need to find device by size (100) or first non-root EBS

# Get root device
ROOT_DEV=$(lsblk -no NAME,MOUNTPOINT | grep ' /$' | awk '{print $1}')

# List all block devices excluding root
ALL_DEVS=$(lsblk -dn -o NAME | grep -v "$ROOT_DEV")

# Choose the first non-root device
DATA_DEV="/dev/${ALL_DEVS%% *}"

# Wait for device to be ready
while [ ! -b "$DATA_DEV" ]; do
  echo "Waiting for $DATA_DEV..."
  sleep 3
done

# Format and mount if not already formatted
if ! blkid "$DATA_DEV"; then
  mkfs.ext4 "$DATA_DEV"
fi

mkdir -p /kafka-data
mount "$DATA_DEV" /kafka-data
chown -R ec2-user:ec2-user /kafka-data
echo "$DATA_DEV /kafka-data ext4 defaults,nofail 0 2" >> /etc/fstab

# Install Kafka

cd /opt

# Download Kafka tar file from S3
aws s3 cp s3://${kafka_bucket}/kafka_2.13-4.2.0.tgz .

# Extract Kafka
tar -xzf kafka_2.13-4.2.0.tgz
mv kafka_2.13-4.2.0 kafka
cd kafka


# Configure KRaft mode

KAFKA_CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)

# Format storage using the mounted EBS

bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties

# Network configuration

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "listeners=PLAINTEXT://0.0.0.0:9092" >> config/kraft/server.properties
echo "advertised.listeners=PLAINTEXT://$PRIVATE_IP:9092" >> config/kraft/server.properties
echo "log.dirs=/kafka-data" >> config/kraft/server.properties

# Start Kafka in background

bin/kafka-server-start.sh -daemon config/kraft/server.properties


# Create initial topic

bin/kafka-topics.sh --create \
  --topic url-clicks \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1
