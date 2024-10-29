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

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch the cluster in."
  default     = ["subnet-0ec69f1dbb29feaa8", "subnet-043514ff6648f3a9b", "subnet-0abf18f6c4a8427e2", "subnet-0a88ef65881802333"]
}

variable "associated_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with the cluster."
  default     = []
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

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS control plane."
  default     = "1.29"
}

variable "create_eks_service_role" {
  type        = bool
  description = "Set to `false` to use an existing EKS cluster service role ARN instead of creating one."
  default     = true
}

variable "eks_cluster_service_role_arn" {
  type        = string
  description = "The ARN of an IAM role for the EKS cluster, used if `create_eks_service_role` is `false`."
  default     = null
}
