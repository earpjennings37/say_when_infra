/*
data "aws_iam_policy_document" "s3_backup" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws-us:s3:::${local.account_id}:${var.cluster_name}-backup-s3/*",
      "arn:aws-us:s3:::${local.account_id}:${var.cluster_name}-backup-s3/"
    ]
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}
*/