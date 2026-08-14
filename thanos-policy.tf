data "aws_iam_policy_document" "thanos_s3" {
  statement {
    sid       = "ThanosBucketLevel"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::thanos-infinity-37"]
  }

  statement {
    sid = "ThanosObjectLevel"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject" # only needed if running the compactor
    ]
    resources = ["arn:aws:s3:::thanos-infinity-37/*"]
  }
}

resource "aws_iam_policy" "thanos_s3_policy" {
  name   = "thanos-s3-policy"
  policy = data.aws_iam_policy_document.thanos_s3.json
}