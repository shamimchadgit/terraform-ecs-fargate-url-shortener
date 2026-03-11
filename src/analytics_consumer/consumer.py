from confluent_kafka import Consumer
import os
import json
import boto3
import time

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP")
TABLE_NAME = os.getenv("TABLE_NAME")

consumer = Consumer({
    "bootstrap.servers": KAFKA_BOOTSTRAP,
    "group.id": "analytics-consumer",
    "auto.offset.reset": "earliest",
    "enable.auto.commit": True
})

consumer.subscribe(["url-clicks"])

AWS_REGION = os.getenv("AWS_REGION")
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(TABLE_NAME)

print("Consumer started...")

try:
    while True:
        msg = consumer.poll(1.0)
    
        if msg is None:
            continue
        if msg.error():
            print("Consumer error:", msg.error())
            continue
    
        event = json.loads(msg.value().decode("utf-8"))
        short_code = event["short_code"]
    
        print("Processing event:", event)
    
#Increment click count
        table.update_item(
            Key={"short_url": short_code},
            UpdateExpression="ADD click_count :inc",
            ExpressionAttributeValues={":inc": 1}
    )
    
        time.sleep(0.1)
except KeyboardInterrupt:
    print("Consumer interrupted. Shutting down...")
finally:
    print("Closing Kafka consumer...")
    consumer.close()