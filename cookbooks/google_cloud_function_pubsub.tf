provider "google" {
  region      = ""
  credentials = ""
  project     = ""
}


# PubSub
resource "google_pubsub_topic" "ps_name" {
  name = "topic-name" 
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
# use pubsub as trigger
resource "google_cloudfunctions_function" "cleanupfirestore" {
  name    = "tf-cloud-funciton"
  runtime = "nodejs10"
  entry_point = "cleanUpFirestore"
   event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "${google_pubsub_topic.ps_name.id}"
  }
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.gcs_source_cleanupfirestore.name}"
}