import os, boto3

TABLE_NAME = os.getenv("TABLE_NAME", "url_shortener_table")
LOCALSTACK_HOST = os.getenv("LOCALSTACK_HOST", "localhost")

endpoint_url = f"http://{LOCALSTACK_HOST}:4566" if LOCALSTACK_HOST else None

dynamodb = boto3.resource(
    "dynamodb",
    region_name=os.getenv("AWS_REGION", "eu-north-1"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", "test"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", "test"),
    endpoint_url=endpoint_url,
)

_table = dynamodb.Table(TABLE_NAME)

def put_mapping(short_id: str, url: str):
    _table.put_item(Item={"shortUrl": short_id, "full_url": url})

def get_mapping(short_id: str):
    resp = _table.get_item(Key={"shortUrl": short_id})
    return resp.get("Item")
