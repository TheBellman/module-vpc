# Example
This example uses the VPC module to stand up a VPC, then install a public and private instance in appropriate subnets.

## Prerequisites
This module does make use of Terraform version constraints (see `versions.tf`) but can be summarised as:

 - Terraform 0.13.4 or above
 - Terraform AWS provider 3.7.0 or above

The example code broadly assumes AWS CLI 2.0.54 or better is available.

## Usage

First, create `terraform.tfvars` using `terraform.tfvars.template` as an example, e.g.:

```
aws_region     = "eu-west-2"
aws_profile    = "adm_rhook_cli"
aws_account_id = "889199313043"
tags           = { Owner = "Robert", Client = "Little Dog Digital", Project = "VPC Module Test" }
vpc_cidr       = "172.21.0.0/16"
vpc_name       = "test"
ssh_inbound    = ["89.35.68.27/32", "18.202.216.48/29", "3.8.37.24/29", "35.180.112.80/29"]
```

In this example we allow SSH from a particular client, plus some additional CIDR blocks from AWS. These additional blocks are needed to allow the use of [Instance Connect](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/) through the AWS console.

These CIDR blocks are available from AWS:

```
wget https://ip-ranges.amazonaws.com/ip-ranges.json
jq '.prefixes[] | select(.service=="EC2_INSTANCE_CONNECT")' < ip-ranges.json
```

Note that use of instance connect can be controlled through [IAM policies](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html). The nice thing about Instance Connect is that we do not need to provision an SSH key onto the instance, and access via SSH from the desktop is managed purely through rights on the IAM principal:

```
mssh -u adm_rhook_cli  i-0b619e1685a0d4742
```

After creating `terraform.tfvars` you will need to update `backend.tf` - see the [Terraform Documentation](https://www.terraform.io/docs/backends/index.html) for more information - you can even remove `backend.tf` competely to keep the Terraform state locally.

Finally, you can apply the example code:

```
terraform init
terraform apply
```

On completion, some useful information should be provided:

```
Apply complete! Resources: 58 added, 0 changed, 0 destroyed.

Outputs:

eip_public_address = 18.134.115.144
private_instance = 172.21.114.125
private_subnet = [
  "172.21.96.0/19",
  "172.21.128.0/19",
  "172.21.160.0/19",
]
public_instance = 35.178.62.175
public_subnet = [
  "172.21.0.0/19",
  "172.21.32.0/19",
  "172.21.64.0/19",
]
vpc_arn = arn:aws:ec2:eu-west-2:889199313043:vpc/vpc-026dcbaa33a863014
vpc_id = vpc-026dcbaa33a863014
```

### Access
As described above, you should be able to use Instance Connect to SSH to the "public" instance, however you will need to use [Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) via the AWS console to connect directly to the "private" instance.

The joy of using Instance Connect / Session Manager is that direct access to the command line on instances is managed purely through IAM permissions, and is audited via Cloud Trail.

## License
Copyright 2020 Little Dog Digital

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
