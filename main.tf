# Main configuration for EKS and related resources

locals {
  enabled                   = var.enabled
  use_ipv6                  = var.kubernetes_network_ipv6_enabled
  eks_cluster_id            = one(aws_eks_cluster.default[*].id)
  cloudwatch_log_group_name = "/aws/eks/${var.namespace}-${var.environment}-${var.name}/cluster"
}

module "this" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # Use the appropriate version

  enabled       = var.enabled
  namespace     = var.namespace
  environment   = var.environment
  delimiter      = var.delimiter
  attributes    = var.attributes
  tags          = var.tags
  labels_as_tags = var.labels_as_tags
}

resource "aws_cloudwatch_log_group" "default" {
  count             = local.enabled && length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cluster_log_retention_period
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = module.this.tags
}

resource "aws_kms_key" "cluster" {
  count                   = local.enabled && var.cluster_encryption_config_enabled && var.cluster_encryption_config_kms_key_id == "" ? 1 : 0
  description             = "EKS Cluster ${var.namespace}-${var.environment}-${var.name} Encryption Config KMS Key"
  enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  tags                    = module.this.tags
}

resource "aws_eks_cluster" "default" {
  count                         = local.enabled ? 1 : 0
  name                          = "${var.namespace}-${var.environment}-${var.name}"
  tags                          = module.this.tags
  role_arn                      = local.eks_service_role_arn
  version                       = var.kubernetes_version
  enabled_cluster_log_types     = var.enabled_cluster_log_types
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons_enabled

  vpc_config {
    security_group_ids      = var.associated_security_group_ids
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = local.use_ipv6 ? [true] : []
    content {
      ip_family = "ipv6"
    }
  }

  depends_on = [
    aws_kms_key.cluster,
    aws_cloudwatch_log_group.default,
    var.subnet_ids,
  ]
}


