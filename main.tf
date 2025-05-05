resource "aws_s3_bucket" "example" {
  bucket = "sample-app-pro-${random_integer.suffix.result}"
  
  tags = {
    Name = "SampleAppBucket"
  }
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}