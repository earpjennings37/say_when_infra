##############################################
/*Input S3 Audio Files*/
##############################################
resource "aws_s3_bucket" "medical_input" {
  bucket = "earp-medical-audio-input"
  tags = {
    Name        = "MedicalAudioInput"
    Environment = "Dev"
  }
}
##############################################
/*Output S3 Transcripts*/
##############################################
resource "aws_s3_bucket" "medical_output" {
  bucket = "earp-medical-output"
  tags = {
    Name        = "MedicalOutput"
    Environment = "Dev"
  }
}
##############################################
/*Medical S3 Results*/
##############################################
resource "aws_s3_bucket" "medical_results" {
  bucket = "earp-medical-results-bucket"
  tags = {
    Name        = "MedicalResults"
    Environment = "Dev"
  }
}