provider "google" {
  region      = ""
  credentials = ""
  project     = ""
}


# PubSub
resource "google_pubsub_topic" "ps_name" {
  name = "topic-name" 
}

# Scheduler
resource "google_cloud_scheduler_job" "scheduler" {
  name        = "scheduler name" 
  description = "desc"
  schedule    = "0 4 1 * *"
  time_zone   = "Europe/Berlin"
  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = "${google_pubsub_topic.ps_name.id}"
    data       = "${base64encode("meaningful message")}"
  }
}