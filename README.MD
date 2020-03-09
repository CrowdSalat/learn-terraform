# learn-terraform

[Tutorial from hashicorp](https://learn.hashicorp.com/terraform/getting-started)

## build Infrastructure
---
**_NOTE_**

Example useses ``profile="default"`` and expects credentials under:
1. ~/.aws/credentials (linux, macOS)
2. %UserProfile%\.aws\credentials (windows)

Therefore install [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and run ``aws configure`` if the credentials folder does not exist yet. 

---

- **provider**s create and manage resources. They wrap the API of a service (provider) like AWS, Azure or GCP.
- If you use multiple providers you can qualifiy which provider uses which resource.
- **resource**s might be a physical reosurce like a aws EC2 instance or a logical resource like a application.
- A resource has a type and a name  ``resource "aws_instance" "example"`{...}`` and can be configured inside the curly brackets.


```shell
terraform init # initializes various local settings 
terraform fmt # format all files in directory
terraform validate # validate file

terraform apply # checks diff between config file and real infrastructure and creates execution plan to elimiate this diff

terraform state # The state of the infrastructure is saved in terraform.tfstate file. It can be manually modified by this command.
```

The next step is adding **provisioning**, which can be some sort of initialisation or software provisioning.

### Change Infrastructure

Just change tf files and rerun ```terraform apply``.

### Destroy Infrastructure

To completely destroy the Terraform-managed infrastructure call ``terraform destroy``.

### Resource Dependencies

There are explicit and implicit dependencies for creating a order of actions.

- explicit: with the **depends_on** field of a resource.
- implicit: e.g. usage of ``instance = aws_instance.example.id``

Resources which are not dependant on others can be build in parallel.

### Provisioning

- Only necessary if you do not use image-based infrastructure.
- provisioner are defined inside a resource and have a type like: ``local-exec`` or ``remote-exec``
- Are for bootstraping component (on creation) not to change software on a running component.
- **You need to destroy the infrastructure if the reosurces arleady exist, so the reosurces will be recreated and the bootstrapping logic of the provisioner can be done.**
- If a resource successfully creates but fails during provisioning, Terraform will error and mark the resource as "tainted".
- Terraform tries to destroy and recreate tainted resources every time *apply* ist called.
- ``terrafirm taint <resource.id>`` manually marks a resource as tainted.


### Input Variables

- variables are defined in a variables.tf file and may be assigned a default value
- variables are accessed with a **var.<variable_name>** notation.
- variables can be overwritten in console: `` terraform apply -var 'region=us-east-2'
- variables can also be overwritten from file. Terraform search automatically for *terraform.tfvars* or **.auto.tfvars* files. Alternativly you can pass a file in console `` terraform apply -var-file 'production.tfvars'.
- variables can be overwritten by enviroment variables. They need to start with **TF_VAR_**<name of variable to overwrite>. Environment variables are limited tostring-type variables (can not use List and map type variables).
- variables which are unspecified are asked for after executing ``terraform apply``

Possibilities in a nutshell:

- preset in variables.tf per *default* field
- overwrite console (``-var 'var_name=var_value'``)
- overwrite in terraform.tfvars file
- overwrite in *.tfvars file and  (``-var-file 'production.tfvars'``)
- overwrite in enviromental variables (TF_VARS_)

Lists:

define: ``variable "cidrs" { type = list }``
init: ``cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ]``

Maps:
define and init:
```terraform
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
```

use:
```terraform
resource "aws_instance" "example" {
  ami           = var.amis["us-east-1"]
  instance_type = "t2.micro"
}
```

### Output Variables
`
Output blocks can be pasted in any of the *.tf files. Output are printed after ``terraform output`` or ``terraform apply`` run.

Example:
```terraform
output "ip" {
  value = aws_eip.ip.public_ip
}
```

### modules

- Modules are self-contained packages of Terraform configurations that are managed as a group.
- any set of Terraform configuration files in a folder is a module.
- [Terraform Registry ](https://registry.terraform.io/) includes a directory of ready-to-use modules for various common purposes
- After adding new modules you need to rerun ``terraform init`` 
- variables.tf: input parameters for the module
- outputs.tf: return values of the module
- Providers should be configured by the user of the module and not by the module itself.
- ``terraform get`` will download modules
- Modules reside under .terraform/modules/<the module alias given in root tf skript e.g. consul>
- if the module is downloaded from a [git repository](https://www.terraform.io/docs/modules/sources.html#generic-git-repository) the whole Repository lies in the module folder.

Example:
```terraform
module "consul" {
  source      = "hashicorp/consul/aws"
  version = "0.7.3" # optional
  num_servers = "3"
}
```

### Remote State Storage

- Use **remote backends** to store statedata  on a server.
- There are different backends. Terraform Cloud is one of such.

Google cloud backend example:
```terraform
 backend "gcs" {
    bucket = "existing-bucket-name"
  }
```

### additional resources

[Further Tutorials](https://learn.hashicorp.com/terraform#operations-and-development) - also for gcp or azure

[Documentation](https://www.terraform.io/docs/index.html) - The documentation is an in-depth reference guide to all the features of Terraform, including technical details about the internals of how Terraform operates.

[Examples](https://www.terraform.io/intro/examples/index.html) - The examples have more full featured configuration files, showing some of the possibilities with Terraform.

[Import](https://www.terraform.io/docs/import/index.html) - The import section of the documentation covers importing existing infrastructure into Terraform.


## cookbooks

### Google Cloud Function - source code management

./cookbooks/google_cloud_function.tf

```terraform
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
```

### Google Cloud Function + PubSub

./cookbooks/google_cloud_function_pubsub.tf

```terraform
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
```

### Google Scheduler + PubSub

./cookbooks/google_scheduler_pubsub.tf

```terraform
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
```