module "this" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  enabled             = var.enabled
  namespace           = var.namespace
  environment         = var.environment
  stage               = var.stage
  name                = var.name
  delimiter           = var.delimiter
  attributes          = var.attributes
  tags                = var.tags
  labels_as_tags      = var.labels_as_tags
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "namespace" {
  type        = string
  default     = null
  description = "ID element. Abbreviation of the organization name, e.g., 'gp' for Gloopro, to ensure unique IDs."
}

variable "environment" {
  type        = string
  default     = null
  description = "ID element indicating environment (e.g., 'prod', 'staging', 'dev')."
}

variable "stage" {
  type        = string
  default     = null
  description = "ID element to specify the stage, e.g., 'build', 'test', 'deploy'."
}

variable "name" {
  type        = string
  default     = null
  description = "ID element for the component name (e.g., 'eks-cluster')."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to use between ID elements. Defaults to '-' (hyphen)."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes to append to ID, joined by the delimiter."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources (e.g., `{'Owner': 'Gloopro'}`)."
}

variable "labels_as_tags" {
  type        = set(string)
  default     = ["default"]
  description = "Set of labels to include as tags in the `tags` output. Default includes all labels."
}
