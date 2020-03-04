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


### Variables

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
```yaml
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
```

use:
```yaml
resource "aws_instance" "example" {
  ami           = var.amis["us-east-1"]
  instance_type = "t2.micro"
}
```
