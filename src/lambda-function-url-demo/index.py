import json
import boto3
import os
import logging
logger = logging.getLogger()
logger.setLevel("INFO")

def lambda_handler(event, context):
    logger.info(json.dumps(event))
    if 'queryStringParameters' in event and 'input1' in event['queryStringParameters']:

        if event['queryStringParameters']['input1'] == "YES":
            response = "Information successfully submitted."
        else:
            response = "Invalid data submitted."

        logger.info(response)

        return {
            'statusCode': 200,
            "isBase64Encoded": False,
            "headers": {"Content-Type": "text/html; charset=utf-8"},
            'body': '<!DOCTYPE html><head><title></title></head><body><div align="center"><br /><h1>' + response + '</h1></body></html>'
        }
    else:
        return {
            'statusCode': 200,
            "isBase64Encoded": False,
            "headers": {"Content-Type": "text/html; charset=utf-8"},
            'body': '<!DOCTYPE html><head><title></title></head><body><div align="center"><br /><h1>Lambda Function URL Demo</h1><h2>Please enter YES to continue:</h2><form action="" method="GET"><label for="input1">Input:</label><input type="text" id="input1" name="input1" size="20" required><input type="submit" value="Submit"></form></div></body></html>'
        }