{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "s3:GetObject",
            "Effect": "Allow",
            "Resource": "${bucket_arn}/*",
            "Principal": {
                "AWS": "${cloudfront_oai_arn}"
            }
        }
    ]
}