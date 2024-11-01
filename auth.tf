data "tls_certificate" "cluster" {
  count = local.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = one(aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
}

resource "aws_iam_openid_connect_provider" "default" {
  count = local.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = one(aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
  tags  = module.this.tags  # Make sure this is correctly referencing the module

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [one(data.tls_certificate.cluster[*].certificates[0].sha1_fingerprint)]
}

locals {
  # Extract the cluster certificate for use in OIDC configuration
  certificate_authority_data = try(aws_eks_cluster.default[0].certificate_authority[0]["data"], "")

  # Map of simplified EKS policies used in Gloopro's setup
  eks_policy_abbreviation_map = {
    "ClusterAdmin" = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
    "View"         = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  }

  # Expand access policies to full ARNs if abbreviated in access_entry_map
  access_entry_expanded_map = { 
    for key, entry in var.access_entry_map : 
    key => merge(entry, {
      access_policy_associations = { 
        for policy, assoc in entry.access_policy_associations : 
        try(local.eks_policy_abbreviation_map[policy], policy) => assoc 
      }
    })
  }

  # Final map replacing "system:masters" with "ClusterAdmin" policy for STANDARD users
  access_entry_map = {
    for key, entry in local.access_entry_expanded_map : key => merge(entry, {
      kubernetes_groups = [for group in entry.kubernetes_groups : group if group != "system:masters" || entry.type != "STANDARD"],
      access_policy_associations = merge(
        entry.access_policy_associations,
        contains(entry.kubernetes_groups, "system:masters") && entry.type == "STANDARD" ? {
          "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" = {}
        } : {}
      )
    })
  }
}

# Main EKS access entry resource based on `access_entry_map`
resource "aws_eks_access_entry" "map" {
  for_each = var.enabled ? local.access_entry_map : {}

  cluster_name      = local.eks_cluster_id
  principal_arn     = each.key
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type

  tags = module.this.tags  # Ensure this references the module correctly
}

# EKS access policy association resource for users in `access_entry_map`
resource "aws_eks_access_policy_association" "map" {
  for_each = var.enabled ? {
    for key, entry in local.access_entry_map : key => {
      principal_arn = key
      policy_arn    = entry.access_policy_associations
    }
  } : {}

  cluster_name  = local.eks_cluster_id
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = local.access_entry_map[each.value.principal_arn].access_policy_associations[each.value.policy_arn].access_scope.type
    namespaces = local.access_entry_map[each.value.principal_arn].access_policy_associations[each.value.policy_arn].access_scope.namespaces
  }
}

# Single access entry for `STANDARD` type, linked to `access_entries`
resource "aws_eks_access_entry" "standard" {
  count = var.enabled ? length(var.access_entries) : 0

  cluster_name      = local.eks_cluster_id
  principal_arn     = var.access_entries[count.index].principal_arn
  kubernetes_groups = var.access_entries[count.index].kubernetes_groups
  type              = "STANDARD"

  tags = module.this.tags  # Ensure this references the module correctly
}
