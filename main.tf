locals {
  enabled                  = var.enabled
  use_ipv6                 = var.kubernetes_network_ipv6_enabled
  eks_cluster_id           = one(aws_eks_cluster.default[*].id)
  cloudwatch_log_group_name = "/aws/eks/${var.namespace}-${var.environment}-${var.name}/cluster"
}

module "this" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled     = var.enabled
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  tags        = var.tags
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

# IAM OpenID Connect Provider for Service Accounts in Kubernetes Cluster
data "tls_certificate" "cluster" {
  count = local.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = one(aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
}

resource "aws_iam_openid_connect_provider" "default" {
  count = local.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = one(aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
  tags  = module.this.tags

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [one(data.tls_certificate.cluster[*].certificates[0].sha1_fingerprint)]
}

resource "aws_eks_addon" "cluster" {
  for_each = local.enabled ? { for addon in var.addons : addon.addon_name => addon } : {}

  cluster_name                = one(aws_eks_cluster.default[*].name)
  addon_name                  = each.key
  addon_version               = lookup(each.value, "addon_version", null)
  configuration_values        = lookup(each.value, "configuration_values", null)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)

  tags = module.this.tags

  depends_on = [
    aws_eks_cluster.default,
    aws_iam_openid_connect_provider.default,
  ]

  timeouts {
    create = each.value.create_timeout
    update = each.value.update_timeout
    delete = each.value.delete_timeout
  }
}