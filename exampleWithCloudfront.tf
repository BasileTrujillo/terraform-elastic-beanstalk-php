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
variable "domain_name" {
  type    = "string"
  default = "app-test.example.io"
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
  source = "github.com/BasileTrujillo/terraform-elastic-beanstalk-php//eb-env"
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
  ssl_certificate_id = "arn:aws:acm:eu-west-1:00000000000:certificate/459fbeb8-e872-4d1f-ba0d-c3cd56175a48"

  # Security
  vpc_id = "vpc-xxxxxxx"
  vpc_subnets = "subnet-xxxxxxx"
  elb_subnets = "subnet-xxxxxxx"
  security_groups = "sg-xxxxxxx"
}

##################################################
## CloudFront
##################################################
module "app_cdn" {
  source              = "github.com/BasileTrujillo/terraform-elastic-beanstalk-php//cloudfront"

  service_name        = "${var.service_name}"
  env                 = "${var.env}"
  origin_domain_name  = "${module.env.eb_cname}"
  domain_name         = "${var.domain_name}"
}

##################################################
## Route53
##################################################
module "app_dns" {
  source      = "github.com/BasileTrujillo/terraform-elastic-beanstalk-php//r53-alias"
  aws_region  = "${var.aws_region}"

  domain              = "example.io"
  domain_name         = "${var.domain_name}"
  eb_cname            = "${module.app_cdn.cf_cname}"
  eb_route53_zone_id  = "${module.app_cdn.cf_hosted_zone_id}"
}
