# tf_wordpress_server
Terraform module for setting up a bare server for using with wordpress. Creates an elastic ip and DNS record, too.

## Assumptions

* Requires:
  * access to AWS 
  * AWS subnet id
  * AWS VPC id
  * SSL certificate/key for created instance
  * Route 53 zone id
  * Terraform >= 0.7
* Uses a public IP and public DNS
* Creates default security group as follows:
  * 22/tcp: SSH
  * 443/tcp: HTTPS
  * 80/tcp: HTTP
* Understand Terraform and ability to read the source

## Usage

Basically, change terraform.tfvars according to your needs, then run `terraform plan`, then `terraform apply`. For tearing everything down, run `terraform destroy`.

1. Clone this repo: `git clone https://github.com/mberndtgen/infracode.git
2. Create a local terraform.tfvars file: `cp terraform.tfvars.example terraform.tfvars`
3. Get dependencies (if needed): `terraform get`
4. Test the plan: `terraform plan`
5. Apply the plan: `terraform apply`

### Module

In your terraform plan:
```
module "module_name_here" {
  source = "github.com/mberndtgen/infracode"
  aws_access_key = "<key>"
  ...
  accept_license = true
  ...
}
```

## Supported OSes
All supported OSes are 64-bit and HVM (though PV should be supported)

* Ubuntu 12.04 LTS
* Ubuntu 14.04 LTS
* Ubuntu 16.04 LTS 
* CentOS 6 (Default)
* CentOS 7 (pending)
* Others (here be dragons! Please see Map Variables)

## AWS

These resources will incur charges on your AWS bill. It is your responsibility to delete the resources.

## Input variables

### AWS variables

* `aws_access_key`: Your AWS key, usually referred to as `AWS_ACCESS_KEY_ID`
* `aws_flavor`: The AWS instance type. Default: `c3.xlarge`
* `aws_key_name`: The private key pair name on AWS to use (String)
* `aws_private_key_file`: The full path to the private kye matching `aws_key_name` public key on AWS
* `aws_region`: AWS region you want to deploy to. Default: `us-west-1`
* `aws_secret_key`: Your secret for your AWS key, usually referred to as `AWS_SECRET_ACCESS_KEY`
* `aws_subnet_id`: The AWS id of the subnet to use. Example: `subnet-ffffffff`
* `aws_vpc_id`: The AWS id of the VPC to use. Example: `vpc-ffffffff`
* `aws_route53_zone_id`: The Route 53 zone id to use.

### other variables

* `allowed_cidrs`: The comma seperated list of addresses in CIDR format to allow SSH access. Default: `0.0.0.0/0`
* `domain`: Server's basename. Default: `localhost`
* `hostname`: Server's basename. Default: `localdomain`
* `log_to_file`: Log chef-client to file. Default: `true`
* `public_ip`: Associate public IP to instance. Default `true`
* `org_short`: Chef organization to create. Default: `chef`
* `org_long`: Chef organization long name. Default: `Chef Organization`
* `root_delete_termination`: Delete root device on VM termination. Default: `true`
* `root_volume_size`: Size of the root volume in GB. Default: `20`
* `root_volume_type`: Type of root volume. Supports `gp2` and `standard`. Default: `standard`
* `tag_description`: Text field tag 'Description'
* `username`: First Chef Server user. Default: `admin`
* `user_email`: Chef Server user's e-mail address. Default: `admin@domain.tld`
* `user_firstname`: Chef Server user's first name. Default: `Admin`
* `user_lastname`: Chef Server user's last name. Default: `User`

### Map variables

The below mapping variables construct selection criteria

* `ami_map`: AMI selection map comprised of `ami_os` and `aws_region`
* `ami_usermap`: Default username selection map based off `ami_os`

The `ami_map` is a combination of `ami_os` and `aws_region` which declares the AMI selected. To override this pre-declared AMI, define

```
ami_map.<ami_os>-<aws_region> = "value"
```

Variable `ami_os` should be one of the following:

* centos6 (default)
* centos7
* ubuntu12
* ubuntu14
* ubuntu16

Variable `aws_region` should be one of the following:

* us-east-1
* us-west-2
* us-west-1 (default)
* eu-central-1
* eu-west-1
* ap-southeast-1
* ap-southeast-2
* ap-northeast-1
* ap-northeast-2
* sa-east-1
* Custom (must be an AWS region, requires setting `ami_map` and setting AMI value)

Map `ami_usermap` uses `ami_os` to look the default username for interracting with the instance. To override this pre-declared user, define

```
ami_usermap.<ami_os> = "value"
```

## Outputs

* `elastic_ip`: The elastic (and public) IP address of the instance
* `private_ip`: The private IP address of the instance
* `security_group_id`: The AWS security group id for this instance

## Contributors

* [Manfred Berndtgen](https://github.com/mberndtgen)

## Contributing

This is a work in progress and is subject to change rapidly. Be sure to keep up to date with the repo should you fork, and feel free to contact me regarding development and suggested direction. 

## `CHANGELOG`

Please refer to the [`CHANGELOG.md`](CHANGELOG.md)

## License

This is licensed under [the Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).

