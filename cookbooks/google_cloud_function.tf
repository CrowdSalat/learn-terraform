provider "google" {
  region      = ""
  credentials = ""
  project     = ""
}

# create bucket for saving source code
resource "google_storage_bucket" "bucket" {
  name = "cloud-function-sources-bucket"
}

# zip local source
data "archive_file" "local_source" {
  type        = "zip"
  source_dir  = "../source_folder"
  output_path = "./source_for_one_function.zip"
  
}

# copy source zip to bucket
resource "google_storage_bucket_object" "gcs_source_cleanupfirestore" {
  name   = "cleanupfirestore.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "${data.archive_file.local_source_cleanupfirestore.output_path}"
}

# create cloud function and use code from source code zip file in bucket
resource "google_cloudfunctions_function" "cleanupfirestore" {
  name    = "tf-cloud-funciton"
  runtime = "nodejs10"
  entry_point = "cleanUpFirestore"
  trigger_http = true
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.gcs_source_cleanupfirestore.name}"
}