resource "aws_dynamodb_table" "visitor_count" {
  name         = "VisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = templatefile("${path.module}/lambda_exec_policy.json.tpl", {})  # The trust policy defines who or what can assume this role 
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_policy"
  description = "Policy for Lambda to access DynamoDB"
  policy = templatefile("${path.module}/lambda_dynamodb_policy.json.tpl", {
    table_arn = aws_dynamodb_table.visitor_count.arn
  }) # Policy template with permissions to read/write to the DynamoDB table, dynamically referencing the table ARN
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "Lambda_S3_Access_Policy"
  policy = templatefile("${path.module}/lambda_s3_access_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "visitor_count_function" {
  function_name = "VisitorCountUpdater"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "visitor_count.lambda_handler"
  runtime       = "python3.9"
  timeout       = 10
  memory_size   = 128
  s3_bucket     = "lambda-py-artifacts"
  s3_key        = "lambda_function.zip" 

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_count.name
    }
  }
}

#API Gateway configurations
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = var.api_name
  description = "API to track website visitors"
}

resource "aws_api_gateway_resource" "visitor_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "visitors"
}

resource "aws_api_gateway_method" "visitor_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "visitor_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method.http_method
  type        = "AWS"
  integration_http_method = "POST"
  uri         = aws_lambda_function.visitor_count_function.invoke_arn
}

resource "aws_api_gateway_method_response" "visitor_method_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "visitor_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method.http_method
  status_code = aws_api_gateway_method_response.visitor_method_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
  response_templates = {
    "application/json" = ""
  }
}

# CORS configuration
resource "aws_api_gateway_method" "visitor_method2" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "visitor_integration2" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method2.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "visitor_integration_response2" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method2.http_method
  status_code = aws_api_gateway_method_response.visitor_method_response2.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "visitor_method_response2" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.visitor_method2.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_count_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/GET/visitors"
}

resource "aws_lambda_permission" "api_gateway_invoke2" {
  statement_id  = "AllowAPIGatewayInvoke2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_count_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/OPTIONS/visitors"
}

resource "aws_api_gateway_deployment" "visitor_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.visitor_resource.id,
      aws_api_gateway_method.visitor_method.id,
      aws_api_gateway_integration.visitor_integration.id,
    ]))
  }  
}

resource "aws_api_gateway_stage" "visitor_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  stage_name    = "dev"
}
