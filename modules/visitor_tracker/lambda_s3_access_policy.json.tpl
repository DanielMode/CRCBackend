{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject"
        ],
        "Effect"   : "Allow",
        "Resource" : "arn:aws:s3:::lambda-py-artifacts/lambda_function.zip" 
      }
    ]
}