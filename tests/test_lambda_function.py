# tests/test_lambda_function.py
import boto3
import pytest
from moto import mock_dynamodb2
from lambda_code.visitor_count import lambda_handler  # adjust import based on your Lambda code structure

@mock_dynamodb2
def test_lambda_handler():
    # Set up the mock DynamoDB environment
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='VisitorCount',
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1},
    )
    table.put_item(Item={'id': 'visitor_count', 'count': 0})

    # Call the lambda handler function
    response = lambda_handler({}, {})

    # Assert the visitor count incremented
    assert response['statusCode'] == 200
    assert response['body'] == 'Visitor count updated'
