variable "namespace" {
  type        = string
  description = "A short identifier for the organization or project to help ensure globally unique resource names."
  default     = "gloopro"
}

variable "environment" {
  type        = string
  description = "The environment for the deployment, e.g., 'production' or 'staging'."
  default     = "production"
}

variable "name" {
  type        = string
  description = "The base name for the EKS cluster."
  default     = "eks-cluster"
}

variable "enabled" {
  type        = bool
  description = "Enable resources."
  default     = true
}

variable "create_eks_service_role" {
  type        = bool
  description = "Set to `false` to use an existing EKS cluster service role ARN instead of creating one."
  default     = true
}

variable "access_entry_map" {
  type        = map(string)
  description = "A map of access entries."
  default     = {}
}

variable "kubernetes_network_ipv6_enabled" {
  type        = bool
  description = "Enable IPv6 for the Kubernetes network."
  default     = false
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS control plane."
  default     = "1.29"
}

variable "bootstrap_self_managed_addons_enabled" {
  type        = bool
  description = "Enable self-managed add-ons for the EKS cluster."
  default     = false
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of enabled log types for the EKS cluster."
  default     = []
}

variable "cluster_log_retention_period" {
  type        = number
  description = "Retention period (in days) for CloudWatch logs."
  default     = 7
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "KMS key ID for CloudWatch log group encryption."
  default     = null
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  description = "Enable encryption configuration for the EKS cluster."
  default     = false
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  description = "KMS key ID for cluster encryption."
  default     = null
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  description = "Enable key rotation for the KMS key used in cluster encryption."
  default     = true
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  description = "Deletion window in days for the KMS key."
  default     = 30
}

variable "permissions_boundary" {
  type        = string
  description = "The ARN of the permissions boundary to attach to the IAM role."
  default     = null
}

variable "eks_cluster_service_role_arn" {
  type        = string
  description = "The ARN of an IAM role for the EKS cluster, used if `create_eks_service_role` is `false`."
  default     = null
}

variable "associated_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with the cluster."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch the cluster in."
  default     = [
    "subnet-0ec69f1dbb29feaa8",
    "subnet-043514ff6648f3a9b",
    "subnet-0abf18f6c4a8427e2",
    "subnet-0a88ef65881802333"
  ]
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enables the Amazon EKS private API server endpoint."
  default     = false
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enables the Amazon EKS public API server endpoint."
  default     = true
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access the Amazon EKS public API server endpoint."
  default     = ["0.0.0.0/0"]
}

variable "oidc_provider_enabled" {
  type        = bool
  description = "Enable the OIDC provider for service accounts."
  default     = false
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "A list of allowed security group IDs."
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "A list of allowed CIDR blocks."
  default     = []
}

variable "custom_ingress_rules" {
  type = list(object({
    source_security_group_id = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
  }))
  description = "Custom ingress rules."
  default     = []
}

variable "access_entries" {
  type = list(object({
    principal_arn     = string
    kubernetes_groups = list(string)
  }))
  description = "A list of access entries."
  default     = []
}

variable "addons" {
  type = list(object({
    addon_name                = string
    addon_version             = string
    configuration_values      = map(string)
    service_account_role_arn  = string
  }))
  description = "A list of addons for the EKS cluster."
  default     = []
}
