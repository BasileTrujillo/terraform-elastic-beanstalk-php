##################################################
## AWS config
##################################################
provider "aws" {
  region = "${var.aws_region}"
}

##################################################
## IAM Roles and profiles
##################################################
resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "${var.service_name}-${var.env}-beanstalk-service-user"
  role = "${aws_iam_role.beanstalk_service.name}"
}
resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "${var.service_name}-${var.env}-beanstalk-ec2-user"
  role = "${aws_iam_role.beanstalk_ec2.name}"
}
resource "aws_iam_role" "beanstalk_service" {
  name = "${var.service_name}-${var.env}-beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role" "beanstalk_ec2" {
  name = "${var.service_name}-${var.env}-beanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "beanstalk_service" {
  name = "${var.service_name}-${var.env}-elastic-beanstalk-service"
  roles = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name = "${var.service_name}-${var.env}-elastic-beanstalk-service-health"
  roles = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
  name = "${var.service_name}-${var.env}-elastic-beanstalk-ec2-web"
  roles = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}


##################################################
## Elastic Beanstalk
##################################################
resource "aws_elastic_beanstalk_environment" "eb_env" {
  name                = "${var.service_name}-${var.env}"
  application         = "${var.service_name}"
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html#concepts.platforms.nodejs
  solution_stack_name = "${var.eb_solution_stack_name} ${var.php_version}"

  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
  # Configure your environment's EC2 instances.
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key_name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${var.security_groups}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_instance_profile.beanstalk_service.name}"
  }

  # Configure your environment to launch resources in a custom VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.vpc_subnets}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:ec2:vpc" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ELBSubnets" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.elb_subnets : var.environmentType}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "${var.public_ip}"
  }

  # Configure your environment's Auto Scaling group.
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.min_instance}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.max_instance}"
  }

  # Configure rolling deployments for your application code.
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "${var.ignore_healthcheck}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "${var.healthreporting}"
  }

  # Configure your environment's architecture and service role.
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "${var.environmentType}"
  }

//  Commented because Terraform think this has changed each apply (even if there is no changes)
//  setting {
//    namespace = "aws:elasticbeanstalk:environment"
//    name      = "LoadBalancerType"
//    value     = "${var.loadBalancerType}"
//  }

  # Configure the default listener (port 80) on a classic load balancer.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:80" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "InstancePort" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.port : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:80" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerEnabled" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.enable_http : var.environmentType}"
  }

  # Configure additional listeners on a classic load balancer.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerProtocol" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? "HTTPS" : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "InstancePort" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.port : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "SSLCertificateId" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.ssl_certificate_id : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerEnabled" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.enable_https : var.environmentType}"
  }

  # Modify the default stickiness and global load balancer policies for a classic load balancer.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:policies" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ConnectionSettingIdleTimeout" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.elb_connection_timeout : var.environmentType}"
  }

  # Configure a health check path for your application. (ELB Healthcheck)
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  # Configure notifications for your environment.
  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Topic ARN"
    value     = "${var.notification_topic_arn}"
  }

  # PHP Platform Options
  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-specific.html#command-options-php
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "document_root"
    value     = "${var.document_root}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "memory_limit"
    value     = "${var.memory_limit}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "zlib.output_compression"
    value     = "${var.zlib_php_compression}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "allow_url_fopen"
    value     = "${var.allow_url_fopen}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "display_errors"
    value     = "${var.display_errors}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "max_execution_time"
    value     = "${var.max_execution_time}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "composer_options"
    value     = "${var.composer_options}"
  }

  # Configure environment properties for your application.
  # EFS Environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EFS_ID"
    value     = "${var.efs_id}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EFS_MOUNT_DIRECTORY"
    value     = "${var.efs_mount_directory}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "${var.aws_region}"
  }
}