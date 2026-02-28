def lambda_handler(event, context):
    # Example: just return event for now
    print("Received event:", event)
    return {
        "statusCode": 200,
        "body": "Hello from Lambda!"
    }
