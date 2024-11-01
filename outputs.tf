output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = one(aws_eks_cluster.default[*].id)
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  value       = one(aws_eks_cluster.default[*].arn)
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = one(aws_eks_cluster.default[*].endpoint)
}

output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = one(aws_eks_cluster.default[*].version)
}

output "eks_cluster_identity_oidc_issuer" {
  description = "The OIDC Identity issuer for the EKS cluster"
  value       = one(aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
}

output "eks_cluster_identity_oidc_issuer_arn" {
  description = "The OIDC Identity issuer ARN for the cluster used to associate IAM roles with a service account"
  value       = one(aws_iam_openid_connect_provider.default[*].arn)  # Ensure this resource is declared in your configuration
}

output "eks_cluster_managed_security_group_id" {
  description = <<-EOT
    Security Group ID created by EKS for the cluster.
    EKS creates a Security Group and applies it to the ENI attached to EKS Control Plane master nodes and to any managed workloads.
    EOT
  value       = one(aws_eks_cluster.default[*].vpc_config[0].cluster_security_group_id)
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = local.eks_service_role_arn  # Ensure local.eks_service_role_arn is defined in your locals
}

output "eks_cluster_ipv4_service_cidr" {
  description = "The IPv4 CIDR block from which Kubernetes pod and service IP addresses are assigned"
  value       = one(aws_eks_cluster.default[*].kubernetes_network_config[0].service_ipv4_cidr)
}
