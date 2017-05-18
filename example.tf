##################################################
## Your variables
##################################################
variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}
variable "env" {
  type = "string"
  default = "dev"
}
variable "service_name" {
  type    = "string"
  default = "php-app-test"
}


##################################################
## AWS config
##################################################
provider "aws" {
  region = "${var.aws_region}"
}


##################################################
## Elastic Beanstalk config
##################################################
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}"
  description = "My awesome nodeJs App"
}

module "env" {
  source = "https://github.com/BasileTrujillo/terraform-elastic-beanstalk-php//eb-env"
  aws_region = "${var.aws_region}"

  # Application settings
  service_name = "${var.service_name}"
  env = "${var.env}"

  # PHP settings
  php_version = "7.0"
  document_root = "/public"
  memory_limit = "512M"
  zlib_php_compression = "Off"
  allow_url_fopen = "On"
  display_errors = "On"
  max_execution_time = "60"
  composer_options = ""

  # Instance settings
  instance_type = "t2.micro"
  min_instance = "1"
  max_instance = "1"

  # ELB
  enable_https = "true"
  elb_connection_timeout = "120"
  ssl_certificate_id = "arn:aws:acm:eu-west-1:596346168805:certificate/459fbeb8-e872-4d0f-ba2d-c3cd9617ea48"

  # Security
  vpc_id = "vpc-827f5ee6"
  vpc_subnets = "subnet-b9ac9ddd"
  elb_subnets = "subnet-d34370b7"
  security_groups = "sg-2885d24e"
  ssh_key_name = "Ireland_VPC"
}

##################################################
## Route53 config
##################################################
module "app_dns" {
  source = "https://github.com/BasileTrujillo/terraform-elastic-beanstalk-php//r53-alias"
  aws_region = "${var.aws_region}"

  domain = "example.io"
  domain_name = "app-test.example.io"
  eb_cname = "${module.env.eb_cname}"
}
