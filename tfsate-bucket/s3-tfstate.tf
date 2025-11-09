terraform {
 backend "s3" {
   bucket         = "919649607464-tfstate-bucket"      # Replace with your S3 bucket name
   key            = "infra/s3.tfstate"       # Path within the bucket
   region         = "eu-west-1"                         # Your AWS region
   encrypt        = true                                # (Optional) Encrypt state file at rest
   profile        = "default"                            # (Optional) AWS CLI profile to use
   #use_lockfile   = true
 }
}