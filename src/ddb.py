import os
import boto3
from botocore.exceptions import ClientError

# Use env vars exactly as your Terraform expects
TABLE_NAME = os.getenv("TABLE_NAME") 
AWS_REGION = os.getenv("AWS_REGION")  

dynamodb = boto3.resource(
    "dynamodb",
    region_name=AWS_REGION
)

table = dynamodb.Table(TABLE_NAME)


def put_mapping(short_url: str, long_url: str):
    try:
        table.put_item(
            Item={
                "short_url": short_url,   # matches hash key in Terraform
                "long_url": long_url
            }
        )
    except ClientError as e:
        raise e


def get_mapping(short_url: str):
    try:
        response = table.get_item(
            Key={
                "short_url": short_url
            }
        )
    except ClientError:
        return None

    return response.get("Item")

