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
```