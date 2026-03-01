##############################################
/*Transcribe Medical IAM Role*/
##############################################
resource "aws_iam_role" "transcribe_role" {
  name = "transcribe-medical-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "transcribe.amazonaws.com"
      }
    }]
  })
}
##############################################
/*Transcribe Medical IAM Policy S3 Access*/
##############################################
resource "aws_iam_role_policy" "transcribe_s3_policy" {
  name = "transcribe-s3-access"
  role = aws_iam_role.transcribe_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.medical_input.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.medical_output.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "${aws_s3_bucket.medical_input.arn}"
      }
    ]
  })
}
##############################################
/*Lambda IAM Role*/
##############################################
resource "aws_iam_role" "lambda_role" {
  name = "lambda-medical-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
##############################################
/*Lambda IAM Policy S3 Access*/
##############################################
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-s3-comprehend"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["comprehendmedical:DetectEntitiesV2"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
        Resource = [
          "${aws_s3_bucket.medical_output.arn}/*",
          "${aws_s3_bucket.medical_results.arn}/*",
          aws_s3_bucket.medical_output.arn,
          aws_s3_bucket.medical_results.arn
        ]
      }
    ]
  })
}
# -----------------------------
# IAM Role for Comprehend Medical
# -----------------------------
resource "aws_iam_role" "comprehend_medical_role" {
  name = "ComprehendMedicalS3Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "comprehendmedical.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# -----------------------------
# IAM Policy for Comprehend Medical
# -----------------------------
resource "aws_iam_policy" "comprehend_s3_policy" {
  name = "ComprehendMedicalS3Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # INPUT bucket permissions
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::earp-medical-output"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::earp-medical-output/*"
      },

      # OUTPUT bucket permissions
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::earp-medical-results-bucket/*"
      }

    ]
  })
}
resource "aws_iam_role_policy_attachment" "comprehend_s3_attach" {
  role       = aws_iam_role.comprehend_medical_role.name
  policy_arn = aws_iam_policy.comprehend_s3_policy.arn
}