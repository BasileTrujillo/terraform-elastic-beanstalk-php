##################################################
## App Variables
##################################################
variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
  description = "The AWS Region"
}

# Application
variable "service_name" {
  type    = "string"
  description = "The application name"
}
variable "env" {
  type    = "string"
  default = "dev"
  description = "The environment (dev, stage, prod)"
}

# Instance
variable "instance_type" {
  type    = "string"
  default = "t2.small"
  description = "The EC2 instance type"
}
variable "ssh_key_name" {
  type    = "string"
  default = "Ireland_VPC"
  description = "The EC2 SSH KeyPair Name"
}
variable "public_ip" {
  type = "string"
  default = "false"
  description = "EC2 instances must have a public ip (true | false)"
}
variable "min_instance" {
  type    = "string"
  default = "1"
  description = "The minimum number of instances"
}
variable "max_instance" {
  type    = "string"
  default = "1"
  description = "The maximum number of instances"
}
variable "deployment_policy" {
  type    = "string"
  default = "Rolling"
  description = "The deployment policy"
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.rolling-version-deploy.html?icmpid=docs_elasticbeanstalk_console
}
variable "environmentType" {
  type    = "string"
  default = "LoadBalanced"
  description = "Set to SingleInstance to launch one EC2 instance with no load balancer."
}

# Load Balancing
variable "loadBalancerType" {
  type    = "string"
  default = "classic"
  description = "The type of load balancer for your environment. (classic, application, network)"
}
variable "port" {
  type    = "string"
  default = "80"
  description = "The instance port"
}
variable "ssl_certificate_id" {
  type    = "string"
  default = ""
  description = "ARN of an SSL certificate to bind to the listener."
}
variable "healthcheck_url" {
  type    = "string"
  default = "/"
  description = "The path to which to send health check requests."
}
variable "ignore_healthcheck" {
  type    = "string"
  default = "false"
  description = "Do not cancel a deployment due to failed health checks. (true | false)"
}
variable "healthreporting" {
  type    = "string"
  default = "basic"
  description = "Health reporting system (basic or enhanced). Enhanced health reporting requires a service role and a version 2 platform configuration."
}
variable "notification_topic_arn" {
  type    = "string"
  default = ""
  description = "Amazon Resource Name for the topic you subscribed to."
}
variable "enable_http" {
  type = "string"
  default = "true"
  description = "Enable or disable default HTTP connection on port 80."
}
variable "enable_https" {
  type = "string"
  default = "true"
  description = "Enable or disable HTTPS connection on port 443."
}
variable "elb_connection_timeout" {
  type = "string"
  default = "60"
  description = "Number of seconds that the load balancer waits for any data to be sent or received over the connection."
}

# Auto Scaling
variable "as_breach_duration" {
  type = "string"
  default = "5"
  description = "Amount of time, in minutes, a metric can be beyond its defined limit (as specified in the UpperThreshold and LowerThreshold) before the trigger fires."
}
variable "as_lower_breach_scale_increment" {
  type = "string"
  default = "-1"
  description = "How many Amazon EC2 instances to remove when performing a scaling activity."
}
variable "as_lower_threshold" {
  type = "string"
  default = "2000000"
  description = "If the measurement falls below this number for the breach duration, a trigger is fired."
}
variable "as_measure_name" {
  type = "string"
  default = "NetworkOut"
  description = "Metric used for your Auto Scaling trigger."
}
variable "as_period" {
  type = "string"
  default = "5"
  description = "Specifies how frequently Amazon CloudWatch measures the metrics for your trigger."
}
variable "as_statistic" {
  type = "string"
  default = "Average"
  description = "Statistic the trigger should use, such as Average."
}
variable "as_unit" {
  type = "string"
  default = "Bytes"
  description = "Unit for the trigger measurement, such as Bytes."
}
variable "as_upper_breachs_scale_increment" {
  type = "string"
  default = "1"
  description = "How many Amazon EC2 instances to add when performing a scaling activity."
}
variable "as_upper_threshold" {
  type = "string"
  default = "6000000"
  description = "If the measurement is higher than this number for the breach duration, a trigger is fired."
}

# PHP Platform Options
# Namespace: aws:elasticbeanstalk:container:php:phpini
variable "eb_solution_stack_name" {
  type    = "string"
  default = "64bit Amazon Linux 2017.03 v2.4.0 running PHP"
  description = "The Elastic Beanstalk solution stack name"
}
variable "php_version" {
  type    = "string"
  default = "7.0"
  description = "The Elastic Beanstalk solution stack name"
}
variable "document_root" {
  type    = "string"
  default = "/"
  description = "Specify the child directory of your project that is treated as the public-facing web root."
}
variable "memory_limit" {
  type    = "string"
  default = "256M"
  description = "Amount of memory allocated to the PHP environment."
}
variable "zlib_php_compression" {
  type    = "string"
  default = "Off"
  description = "Specifies whether or not PHP should use compression for output."
}
variable "allow_url_fopen" {
  type    = "string"
  default = "On"
  description = "Specifies if PHP's file functions are allowed to retrieve data from remote locations, such as websites or FTP servers."
}
variable "display_errors" {
  type    = "string"
  default = "Off"
  description = "Specifies if error messages should be part of the output."
}
variable "max_execution_time" {
  type    = "string"
  default = "60"
  description = "Sets the maximum time, in seconds, a script is allowed to run before it is terminated by the environment."
}
variable "composer_options" {
  type    = "string"
  default = ""
  description = "Sets custom options to use when installing dependencies using Composer through composer.phar install."
  # For more information including available options, go to http://getcomposer.org/doc/03-cli.md#install.
}

# Security
variable "vpc_id" {
  type    = "string"
  description = "The ID for your VPC."
}
variable "vpc_subnets" {
  type    = "string"
  description = "The IDs of the Auto Scaling group subnet or subnets."
}
variable "elb_subnets" {
  type    = "string"
  description = "The IDs of the subnet or subnets for the elastic load balancer."
}
variable "security_groups" {
  type    = "string"
  default = "elasticbeanstalk-default"
  description = "Lists the Amazon EC2 security groups to assign to the EC2 instances in the Auto Scaling group in order to define firewall rules for the instances."
}

# Elastic File Storage (Environment variables)
variable "efs_id" {
  type    = "string"
  default = ""
  description = "The EFS ID to put in an EB Environment variable called EFS_ID."
}
variable "efs_mount_directory" {
  type    = "string"
  default = ""
  description = "The EFS Mount Directory to put in an EB Environment variable called EFS_MOUNT_DIRECTORY."
}