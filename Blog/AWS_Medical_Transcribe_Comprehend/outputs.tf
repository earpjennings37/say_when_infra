output "transcribe_role_arn" {
  value = aws_iam_role.transcribe_role.arn
}
output "medical_input_bucket_name" {
  value = aws_s3_bucket.medical_input.bucket
}
output "medical_output_bucket_name" {
  value = aws_s3_bucket.medical_output.bucket
}
output "medical_results_bucket_name" {
  value = aws_s3_bucket.medical_results.bucket
}