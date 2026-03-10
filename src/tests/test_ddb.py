import os
from producer_app.ddb import put_mapping, get_mapping

# localStack setup
os.environ["AWS_REGION"] = "eu-west-2"
os.environ["TABLE_NAME"] = "url_shortener_table"
os.environ["LOCALSTACK_HOST"] = "localhost"

def test_put_and_get_mapping():
    short_id = "test123"
    url = "https://example.com"

    # Put the item
    put_mapping(short_id, url)

    # Get the item
    item = get_mapping(short_id)
    
    assert item is not None
    assert item["short_url"] == short_id
    assert item["long_url"] == url
