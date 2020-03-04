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
