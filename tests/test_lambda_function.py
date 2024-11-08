# tests/test_lambda_function.py

import boto3
import pytest
from moto import mock_aws
from lambda_code.visitor_count import lambda_handler  # Adjust the import based on your structure

@mock_aws
def test_lambda_handler():
    # Set up the mock DynamoDB environment
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='VisitorCount',
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1},
    )
    table.wait_until_exists()
    table.put_item(Item={'id': 'visitor_count', 'count': 0})

    # Call the lambda handler function
    response = lambda_handler({}, {})

    # Assert the visitor count incremented
    assert response['statusCode'] == 200
    # Assuming the lambda_handler returns a JSON string with the new count
    assert "Visitor count is now 1" in response['body']

    # Verify DynamoDB update
    updated_item = table.get_item(Key={'id': 'visitor_count'})['Item']
    assert updated_item['count'] == 1

