resource "aws_lambda_function" "process_transcript" {
  function_name = "process-medical-transcript"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"
}