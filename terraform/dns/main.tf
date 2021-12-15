terraform {
  backend "s3" {
    profile        = "ipfs"
    bucket         = "ipfs-aws-terraform-state"
    dynamodb_table = "ipfs-aws-terraform-state-lock"
    region         = "us-west-2"
    key            = "terraform.dns.tfstate"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = "ipfs"
  region  = "us-west-2"
  default_tags {
    tags = {
      Team        = "NearForm"
      Project     = "AWS-IPFS"
      Environment = "POC"
      Subsystem   = "DNS"
      ManagedBy   = "Terraform"
    }
  }
}

data "terraform_remote_state" "peer" {
  backend = "s3"
  config = {
    bucket = "ipfs-aws-terraform-state"
    key    = "terraform.peer.tfstate"
    region = "${local.region}"
  }
}

data "terraform_remote_state" "indexing" {
  backend = "s3"
  config = {
    bucket = "ipfs-aws-terraform-state"
    key    = "terraform.indexing.tfstate"
    region = "${local.region}"
  }
}

resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# resource "aws_route53_record" "ingress_load_balancer_subdomains" {
#   for_each = toset(var.subdomains_loadbalancer) # TODO: Get those from ingress host list?
#   zone_id = aws_route53_zone.hosted_zone.zone_id
#   name    = "${each.key}.${var.domain_name}" 
#   type    = "CNAME"
#   ttl     = "300"
#   records = [data.terraform_remote_state.peer.outputs.ingress_load_balancer_hostname]
# }

resource "aws_route53_record" "peer_bitswap_load_balancer" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "${var.subdomains_bitwsap_loadbalancer}.${var.domain_name}" 
  type    = "CNAME"
  ttl     = "300"
  records = [data.terraform_remote_state.peer.outputs.bitswap_load_balancer_hostname]
}

resource "aws_route53_record" "provider_load_balancer" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "${var.subdomains_provider_loadbalancer}.${var.domain_name}" 
  type    = "CNAME"
  ttl     = "300"
  records = [data.terraform_remote_state.peer.outputs.provider_load_balancer_hostname]
}

### API Gateway
resource "aws_api_gateway_domain_name" "api" { 
  domain_name              = local.api_domain
  regional_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = data.terraform_remote_state.indexing.outputs.api_id
  stage_name  = data.terraform_remote_state.indexing.outputs.stage_name
  base_path = data.terraform_remote_state.indexing.outputs.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = aws_route53_zone.hosted_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}
