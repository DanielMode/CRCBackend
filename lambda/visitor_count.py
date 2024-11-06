import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitorCount')

    # Retrieve the current count from DynamoDB (assuming the 'id' is always 'visitor_count')
    response = table.get_item(Key={'id': 'visitor_count'})
    current_count = response.get('Item', {}).get('count', 0)

    # Increment the visitor count
    new_count = current_count + 1

    # Update the count in DynamoDB
    table.put_item(Item={'id': 'visitor_count', 'count': new_count})

    return {
        'statusCode': 200,
        "headers": {
             "Access-Control-Allow-Origin": "*",
             "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
             "Access-Control-Allow-Headers": "Content-Type"
         },
        'body': f"Visitor count is now {new_count}"
    }
